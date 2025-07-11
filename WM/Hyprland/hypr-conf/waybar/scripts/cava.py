#!/usr/bin/env python3

import subprocess
import os
import signal
import sys
import time
import tempfile

CAVA_CONFIG_TEMPLATE = """
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
"""

class CavaController:
    BAR_SYMBOLS = '▁▂▃▄▅▆▇█'  # 图形字符，从低到高
    BARS = 250
    FRAMERATE = 60
    BIT_FORMAT = "128bit"
    DEFAULT_VALUES = "0;" * BARS

    def __init__(self):
        self.cava_process = None
        self.temp_config_file = None
        signal.signal(signal.SIGINT, self.handle_signal)
        signal.signal(signal.SIGTERM, self.handle_signal)

    def generate_temp_config(self):
        """
        生成临时CAVA配置文件
        """
        cava_config = CAVA_CONFIG_TEMPLATE % (self.BARS, self.FRAMERATE, len(self.BAR_SYMBOLS) - 1, self.BIT_FORMAT)

        # 创建临时文件，并写入CAVA配置内容
        self.temp_config_file = tempfile.NamedTemporaryFile(delete=False, mode='w', suffix='.conf')
        self.temp_config_file.write(cava_config)
        self.temp_config_file.close()  # 关闭文件以确保数据写入磁盘
        print(f"Temporary CAVA config created at: {self.temp_config_file.name}")

    def start_cava(self):
        """
        启动CAVA进程，使用生成的临时配置文件
        """
        self.generate_temp_config()
        try:
            print("Starting CAVA...")
            self.cava_process = subprocess.Popen(
                ["cava", "-p", self.temp_config_file.name],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True
            )
            print(f"CAVA started with PID: {self.cava_process.pid}")
        except FileNotFoundError:
            print("CAVA is not installed or not found in the PATH.")
        except Exception as e:
            print(f"Failed to start CAVA: {e}")

    def monitor_output(self):
        """
        实时监控CAVA的输出并将其转换为图形字符
        """
        if self.cava_process and self.cava_process.stdout:
            try:
                while True:
                    # 读取CAVA的实时输出
                    output = self.cava_process.stdout.readline().strip()
                    if output:
                        # 处理CAVA输出并转换为图形字符
                        visual_output = self.convert_to_bars(output)
                        print(visual_output)
                    else:
                        break
            except KeyboardInterrupt:
                print("Monitoring interrupted.")
            finally:
                self.stop_cava()

    def convert_to_bars(self, cava_output):
        """
        将CAVA的输出转换为图形字符条
        """
        try:
            if cava_output == self.DEFAULT_VALUES:
                return ""
            # 将CAVA输出的字符串转换为数值列表
            values = list(map(int, cava_output.split(";")[:-1]))
            # 将CAVA的数值映射到 '▁▂▃▄▅▆▇█' 中的一个字符
            bars = [self.BAR_SYMBOLS[value] for value in values]
            return ''.join(bars)
        except Exception as e:
            print(f"Error in converting CAVA output: {e}")
            return ""

    def stop_cava(self):
        """
        停止CAVA进程，并删除临时配置文件
        """
        if self.cava_process:
            print("Stopping CAVA...")
            try:
                self.cava_process.terminate()
                self.cava_process.wait(timeout=5)
                print("CAVA terminated.")
            except subprocess.TimeoutExpired:
                print("CAVA did not terminate in time. Force killing.")
                self.cava_process.kill()
            finally:
                self.cava_process = None

        # 删除临时配置文件
        if self.temp_config_file:
            try:
                os.remove(self.temp_config_file.name)
                print(f"Deleted temporary config file: {self.temp_config_file.name}")
            except Exception as e:
                print(f"Failed to delete temporary config file: {e}")

    def handle_signal(self, signum, frame):
        """
        处理信号（SIGINT、SIGTERM），确保CAVA被正确停止
        """
        print(f"Received signal {signum}. Terminating CAVA and exiting...")
        self.stop_cava()
        sys.exit(0)

if __name__ == "__main__":
    cava_controller = CavaController()

    # 启动CAVA
    cava_controller.start_cava()

    # 等待CAVA启动，等待一段时间以确保CAVA已准备好输出
    time.sleep(1)

    # 监控CAVA的输出并转换为图形字符
    cava_controller.monitor_output()

