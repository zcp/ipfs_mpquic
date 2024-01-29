package main

import (
	"archive/zip"
	"bufio"
	"bytes"
	"compress/flate"
	"github.com/cyberdelia/lzo"
	//"compress/gzip"
	"compress/zlib"
	"fmt"
	"github.com/golang/snappy"
	"github.com/klauspost/compress/zstd"
	"github.com/pierrec/lz4"
	"github.com/ulikunitz/xz/lzma"
	"io"
	"os"
	"time"
)

type CompressMode int

//lz4,zip,lzma2,zstd,lzop,snappy,zlib
const (
	Unknow     CompressMode = iota
	ZipMode                 // zip
	LzoMode                 // lzo
	SnappyMode              // snappy
	ZlibMode                // zlib
	Lz4Mode                 //lz4
	ZstdMode                //zstd
	Lzma2Mode               //lzma2
)

type Compresser struct {
	inFile       *os.File
	inFileMode os.FileMode
	outFile    *os.File
	absPath    string
	originSize   int64
	compressSize int64
	writer       io.Writer //not use
	modeStr      string
	startTime    time.Time
	sinceTime    time.Duration
}

func New(input string) (*Compresser, error) {
	fi, err := os.Stat(input)
	if err != nil {
		return nil, err
	}
	if fi.IsDir() {
		return nil, fmt.Errorf("error read: because  %s is dir", input)
	}
	c := &Compresser{inFileMode: fi.Mode(), originSize: fi.Size(), absPath: fi.Name(), startTime: time.Now()}
	c.inFile, err = os.Open(input)
	return c, err
}

func (c *Compresser) NewOutFile(out string) error {
	file, err := os.OpenFile(out, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0666)
	if err != nil {
		return err
	}
	c.outFile = file
	return nil
}

func (c *Compresser) FileClose() error {
	err := c.inFile.Close()
	if err != nil {
		return err
	}
	err = c.outFile.Close()
	if err != nil {
		return err
	}
	return nil
}

func (c *Compresser) InfoPrint() {
	fmt.Printf("使用%s压缩, 原始文件大小:%s, 压缩后大小:%s, 耗时:%v\n",
		c.modeStr, Bytes(uint64(c.originSize)), Bytes(uint64(c.compressSize)), c.sinceTime)
}
func (c *Compresser) UseZipWriter(out string) (int, error) {
	err := c.NewOutFile(out)
	if err != nil {
		return 0, err
	}
	info, _ := c.inFile.Stat()

	zw := zip.NewWriter(c.outFile)
	defer zw.Close()

	// 获取压缩头信息
	head, err := zip.FileInfoHeader(info)
	if err != nil {
		return 0, err
	}
	// 指定文件压缩方式 默认为 Store 方式 该方式不压缩文件 只是转换为zip保存
	head.Method = zip.Deflate
	fw, err := zw.CreateHeader(head)
	if err != nil {
		return 0, err
	}
	// 写入文件到压缩包中
	_, err = io.Copy(fw, c.inFile)
	if err != nil {
		return 0, err
	}
	info, _ = c.outFile.Stat()
	size := info.Size()
	c.compressSize = size
	return int(size), err
}
func (c *Compresser) UseLzoWriter(out string) (int, error) {
	err := c.NewOutFile(out)
	if err != nil {
		return 0, err
	}

	// read rawfile content into buffer
	rawbytes := make([]byte, c.originSize)
	buffer := bufio.NewReader(c.inFile)
	_, err = buffer.Read(rawbytes)
	if err != nil {
		return 0, err
	}

	var buf bytes.Buffer
	writer := lzo.NewWriter(&buf)
	_, err = writer.Write(rawbytes)
	if err != nil {
		return 0, err
	}
	err = writer.Close()
	if err != nil {
		return 0, err
	}

	//err = ioutil.WriteFile(c.absPath+".zlib", buf.Bytes(), c.inFileMode)
	size, err := c.outFile.Write(buf.Bytes())
	if err != nil {
		return 0, err
	}
	c.compressSize = int64(size)

	return size, err
}
func (c *Compresser) UseSnappyWriter(out string) (int, error) {
	err := c.NewOutFile(out)
	if err != nil {
		return 0, err
	}

	// read rawfile content into buffer
	rawbytes := make([]byte, c.originSize)
	buffer := bufio.NewReader(c.inFile)
	_, err = buffer.Read(rawbytes)
	if err != nil {
		return 0, err
	}

	var buf bytes.Buffer
	writer := snappy.NewBufferedWriter(&buf)
	_, err = writer.Write(rawbytes)
	if err != nil {
		return 0, err
	}
	err = writer.Close()
	if err != nil {
		return 0, err
	}

	//err = ioutil.WriteFile(c.absPath+".zlib", buf.Bytes(), c.inFileMode)
	size, err := c.outFile.Write(buf.Bytes())
	if err != nil {
		return 0, err
	}
	c.compressSize = int64(size)

	return size, err
}

func (c *Compresser) UseZstdWriter(out string) (int, error) {
	err := c.NewOutFile(out)
	if err != nil {
		return 0, err
	}

	// read rawfile content into buffer
	rawbytes := make([]byte, c.originSize)
	buffer := bufio.NewReader(c.inFile)
	_, err = buffer.Read(rawbytes)
	if err != nil {
		return 0, err
	}

	var buf bytes.Buffer
	writer, err := zstd.NewWriter(&buf)
	_, err = writer.Write(rawbytes)
	err = writer.Close()
	if err != nil {
		return 0, err
	}

	//err = ioutil.WriteFile(c.absPath+".zlib", buf.Bytes(), c.inFileMode)
	size, err := c.outFile.Write(buf.Bytes())
	if err != nil {
		return 0, err
	}
	c.compressSize = int64(size)

	return size, err
}

func (c *Compresser) UseLzma2Writer(out string) (int, error) {
	err := c.NewOutFile(out)
	if err != nil {
		return 0, err
	}

	// read rawfile content into buffer
	rawbytes := make([]byte, c.originSize)
	buffer := bufio.NewReader(c.inFile)
	_, err = buffer.Read(rawbytes)
	if err != nil {
		return 0, err
	}

	var buf bytes.Buffer
	writer, err := lzma.NewWriter2(&buf)
	_, err = writer.Write(rawbytes)
	err = writer.Close()
	if err != nil {
		return 0, err
	}

	//err = ioutil.WriteFile(c.absPath+".zlib", buf.Bytes(), c.inFileMode)
	size, err := c.outFile.Write(buf.Bytes())
	if err != nil {
		return 0, err
	}
	c.compressSize = int64(size)

	return size, err
}

func (c *Compresser) UseZlibWriter(out string) (int, error) {
	err := c.NewOutFile(out)
	if err != nil {
		return 0, err
	}

	// read rawfile content into buffer
	rawbytes := make([]byte, c.originSize)
	buffer := bufio.NewReader(c.inFile)
	_, err = buffer.Read(rawbytes)
	if err != nil {
		return 0, err
	}

	var buf bytes.Buffer
	writer := zlib.NewWriter(&buf)
	_, err = writer.Write(rawbytes)
	if err != nil {
		return 0, err
	}
	err = writer.Close()
	if err != nil {
		return 0, err
	}

	//err = ioutil.WriteFile(c.absPath+".zlib", buf.Bytes(), c.inFileMode)
	size, err := c.outFile.Write(buf.Bytes())
	if err != nil {
		return 0, err
	}
	c.compressSize = int64(size)

	return size, err
}
func (c *Compresser) UseLz4Writer(out string) (int, error) {
	err := c.NewOutFile(out)
	if err != nil {
		return 0, err
	}

	// read rawfile content into buffer
	rawbytes := make([]byte, c.originSize)
	buffer := bufio.NewReader(c.inFile)
	_, err = buffer.Read(rawbytes)
	if err != nil {
		return 0, err
	}

	var buf bytes.Buffer
	writer := lz4.NewWriter(&buf)
	_, err = writer.Write(rawbytes)
	if err != nil {
		return 0, err
	}
	err = writer.Close()
	if err != nil {
		return 0, err
	}

	//err = ioutil.WriteFile(c.absPath+".zlib", buf.Bytes(), c.inFileMode)
	size, err := c.outFile.Write(buf.Bytes())
	if err != nil {
		return 0, err
	}
	c.compressSize = int64(size)

	return size, err
}
func (c *Compresser) UseFlateWriter(out string) (io.Writer, error) {
	file, err := os.OpenFile(out, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0666)
	if err != nil {
		return nil, err
	}
	c.outFile = file
	w, err := flate.NewWriter(file, flate.BestSpeed)
	return w, err
}

func (c *Compresser) WithMode(mode CompressMode) (string,error) {
	var err error
	var modStr string
	var outName string
	switch mode {
	case ZipMode:
		modStr = "ZIP"
		outName=fmt.Sprintf("%s.zip", c.inFile.Name())
		_, err = c.UseZipWriter(outName)
	case LzoMode:
		modStr = "LZO"
		outName=fmt.Sprintf("%s.lzo", c.inFile.Name())
		_, err = c.UseLzoWriter(outName)
	case SnappyMode:
		modStr = "SNAPPY"
		outName=fmt.Sprintf("%s.snappy", c.inFile.Name())
		_, err = c.UseSnappyWriter(outName)
	case ZlibMode:
		modStr = "ZLIB"
		outName=fmt.Sprintf("%s.zlib", c.inFile.Name())
		_, err = c.UseZlibWriter(outName)
	case Lz4Mode:
		modStr = "LZ4"
		outName=fmt.Sprintf("%s.lz4", c.inFile.Name())
		_, err = c.UseLz4Writer(outName)
	case ZstdMode:
		modStr = "ZSTD"
		outName=fmt.Sprintf("%s.zstd", c.inFile.Name())
		_, err = c.UseZstdWriter(outName)
	case Lzma2Mode:
		modStr = "LZMA2"
		outName=fmt.Sprintf("%s.lzma2", c.inFile.Name())
		_, err = c.UseLzma2Writer(outName)
		/*case FlateMode:
		modStr="FLATE"
		writer,err = c.UseFlateWriter(fmt.Sprintf("%s.flate",c.inFile.Name()))*/

	}

	c.modeStr = modStr
	c.sinceTime = time.Since(c.startTime)
	return outName,err
}
