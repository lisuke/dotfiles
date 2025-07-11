package main

import (
	"bufio"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"
)

const (
	BAR_SYMBOLS = "▁▂▃▄▅▆▇█" // 图形字符，从低到高
	BARS        = 250
	FRAMERATE   = 60
	BIT_FORMAT  = "128bit"
)

var (
	DEFAULT_VALUES = "0;" + strings.Repeat("0;", BARS-1)
	BARS_RUNES     = []rune(BAR_SYMBOLS)
	cavaProcess    *exec.Cmd
	tempConfigFile string
)

func generateTempConfig() (string, error) {
	cavaConfig := fmt.Sprintf(`
[general]
bars = %d
framerate = %d
autosens = 1

[output]
method = raw
channels = mono
data_format = ascii
ascii_max_range = %d
bit_format = %s
`, BARS, FRAMERATE, len(BARS_RUNES)-1, BIT_FORMAT)

	// 创建临时文件并写入配置内容
	tempFile, err := ioutil.TempFile("", "cava_config_*.conf")
	if err != nil {
		return "", err
	}

	defer tempFile.Close()

	if _, err := tempFile.WriteString(cavaConfig); err != nil {
		return "", err
	}

	fmt.Printf("Temporary CAVA config created at: %s\n", tempFile.Name())
	return tempFile.Name(), nil
}

func startCava() (*exec.Cmd, io.ReadCloser, error) {
	var err error
	tempConfigFile, err = generateTempConfig()
	if err != nil {
		return nil, nil, err
	}

	fmt.Println("Starting CAVA...")
	cavaProcess = exec.Command("cava", "-p", tempConfigFile)

	// 设置输出为管道
	stdoutPipe, err := cavaProcess.StdoutPipe()
	if err != nil {
		return nil, nil, err
	}

	stderrPipe, err := cavaProcess.StderrPipe()
	if err != nil {
		return nil, nil, err
	}

	if err := cavaProcess.Start(); err != nil {
		return nil, nil, err
	}

	fmt.Printf("CAVA started with PID: %d\n", cavaProcess.Process.Pid)

	go func() {
		scanner := bufio.NewScanner(stderrPipe)
		for scanner.Scan() {
			fmt.Println("CAVA stderr:", scanner.Text())
		}
	}()

	return cavaProcess, stdoutPipe, nil
}

func monitorOutput(stdoutPipe io.ReadCloser) {
	scanner := bufio.NewScanner(stdoutPipe)
	ticker := time.NewTicker(time.Second / 60) // 每秒 30 次
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			if scanner.Scan() {
				output := scanner.Text()
				if output != "" {
					visualOutput := convertToBars(output)
					fmt.Println(visualOutput)
				}
			} else {
				// 如果没有更多的输出，退出循环
				return
			}
		}
	}
}

func convertToBars(cavaOutput string) string {
	if strings.Compare(cavaOutput, DEFAULT_VALUES) == 0 {
		return ""
	}

	valuesStr := strings.Split(strings.TrimRight(cavaOutput, ";"), ";")
	targetRunes := make([]rune, len(valuesStr))

	for i, v := range valuesStr[:] {
		value, err := strconv.Atoi(v)
		if err != nil {
			fmt.Println("Error converting output:", err)
			return ""
		}
		targetRunes[i] = BARS_RUNES[value]
	}

	return string(targetRunes)
}

func stopCava() {
	if cavaProcess != nil {
		fmt.Println("Stopping CAVA...")
		if err := cavaProcess.Process.Signal(syscall.SIGTERM); err != nil {
			fmt.Println("Failed to terminate CAVA, force killing:", err)
			cavaProcess.Process.Kill()
		}
		cavaProcess.Wait()
		cavaProcess = nil
	}

	if tempConfigFile != "" {
		if err := os.Remove(tempConfigFile); err != nil {
			fmt.Println("Failed to delete temporary config file:", err)
		} else {
			fmt.Println("Deleted temporary config file:", tempConfigFile)
		}
	}
}

func handleSignal(sig os.Signal) {
	fmt.Printf("Received signal %s. Terminating CAVA and exiting...\n", sig)
	stopCava()
	os.Exit(0)
}

func main() {
	// 捕捉系统信号
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		sig := <-sigs
		handleSignal(sig)
	}()

	// 启动CAVA
	_, stdoutPipe, err := startCava()
	if err != nil {
		fmt.Println("Failed to start CAVA:", err)
		return
	}

	// 等待CAVA启动
	time.Sleep(1 * time.Second)

	// 监控CAVA的输出
	monitorOutput(stdoutPipe)

	// 程序结束时确保CAVA进程终止
	defer stopCava()
}
