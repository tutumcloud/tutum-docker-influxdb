package utils

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

const DefaultPath = "/Users/AllenSun/Downloads"

var InitSize string  

func init(){
	InitSize, _ = GetDiskSize()
}

func GetDiskSize() (string, error){
	fmt.Println("Start Get Size")
	path := os.Getenv("VOLUME_PATH")
	if path == "" {
		path = DefaultPath
	}

	//check if path exists
	if _,err := os.Stat(path); err != nil {
		return "" , fmt.Errorf("Container has no path %s", path)
	}

	//Shell cmd to use 'du' to collect disk space under 'path'
	//tail -1 just returns the last row, default is byte caculated.
	//take care of space when constructing cmd
	cmd := "du -h " + path + "| tail -1 | awk '{print $1}'"

	diskSizeStr, err := ExecShell(cmd)
	fmt.Println("DiskSize " + diskSizeStr)
	if err != nil {
		fmt.Println("Can not execute the command shell")
		return "", fmt.Errorf("Can not execute the command shell")
	}

	//split the '\n' at the end of diskSizeStr
	diskSizeStr = strings.Replace(diskSizeStr, "\n", "", -1)  

	return diskSizeStr, nil
}

func ExecShell(cmd string) (string, error) {
	out, err := exec.Command("/bin/sh", "-c", cmd).Output()
	if err != nil {
		return "", err
	}
	result := string(out[:len(out)])
	return result, nil
}