#!/usr/bin/env python

import json
import requests

data = {
	"tooltip": "",
	"status": True
}

subscribe = ["archlinux", "archlinuxcn"]

resp = requests.get("https://mirrors.tuna.tsinghua.edu.cn/static/tunasync.json").json()


for repo in resp:
	if repo["name"] in subscribe:
		name = repo["name"]
		status = repo["status"]
		if status != "success":
			data["status"] = False

		data["tooltip"] += f"name:{name} status: {status}\n"


if data["status"] == True:
	import os
	packages = int(os.popen("checkupdates | wc -l").read())
	data["text"] = f" {packages} " if packages else " "


print(json.dumps(data))

