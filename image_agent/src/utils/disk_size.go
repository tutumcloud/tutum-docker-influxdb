package utils

import (
	"fmt"
	"os"
	"strconv"
	"os/exec"
	"strings"
)

var DefaultPath = "/data"
// Check if the GetDiskSize is called by init()
var isFirst = true

var InitSize string  

func init(){
	InitSize, _ = GetDiskSize()
}

func GetDiskSize() (string, error){
	fmt.Println("Start Get Size")
	// Get Volume Path from env, default to be /data
	// Do not forget to add env VOLUME_PATH in Dockerfile
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
	if isFirst == true {
		isFirst = false
		return diskSizeStr, nil
	}else{
		//diskSizeStr is like 12K, 32M, 48G ...
		a, err := convert(diskSizeStr)
		if err != nil {
			return "",fmt.Errorf("strconv a error")
		}
		b, err := convert(InitSize)
		if err != nil {
			return "",fmt.Errorf("strconv a error")
		}
		actualSize := a - b
		actualSizeStr := strconv.Itoa(actualSize)
		return actualSizeStr, nil
	}
}

func convert(a string) (int,error) {
	i := len(a)
	unit := a[i-1]
	number,_ := strconv.Atoi(a[:i-1])

	var result int
	if unit =='G'{
		result = number * 1024 * 1024
	}else if unit == 'M' {
		result = number * 1024
	}else{
		return -1, "convert error"
	}
	return result, nil	
}


func ExecShell(cmd string) (string, error) {
	out, err := exec.Command("/bin/sh", "-c", cmd).Output()
	if err != nil {
		return "", err
	}
	result := string(out[:len(out)])
	return result, nil
}