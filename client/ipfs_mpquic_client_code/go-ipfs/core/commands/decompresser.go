package commands

import (
	"archive/zip"
	"bytes"
	"compress/zlib"
	"errors"
	"fmt"
	"github.com/cyberdelia/lzo"
	"github.com/golang/snappy"
	"github.com/klauspost/compress/zstd"
	"github.com/pierrec/lz4"
	"github.com/ulikunitz/xz/lzma"
	"io"
	"os"
)

type CompressMode int

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
	inFile     *os.File
	ouFile     *os.File
	absPath    string
	originSize int64
	reader     io.Reader
	modeStr    string
}

func New(input string) (*Compresser, error) {
	fi, err := os.Stat(input)
	if err != nil {
		return nil, err
	}
	if fi.IsDir() {
		return nil, fmt.Errorf("error read: because  %s is dir", input)
	}
	c := &Compresser{originSize: fi.Size(), absPath: fi.Name()}

	c.inFile, err = os.Open(input)
	return c, err
}

func (c *Compresser) NewOutFile(out string) error {
	file, err := os.OpenFile(out, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0666)
	if err != nil {
		return err
	}
	c.ouFile = file
	return nil
}

func (c *Compresser) UseSnappyReader() (io.Reader, error) {
	return snappy.NewReader(c.inFile), nil
}

func (c *Compresser) UseZstdReader() (io.Reader, error) {
	reader, err := zstd.NewReader(c.inFile)
	if err != nil {
		return nil, err
	}
	return reader, err
}

func (c *Compresser) UseLzoReader() (io.Reader, error) {
	reader, err := lzo.NewReader(c.inFile)
	if err != nil {
		return nil, err
	}
	return reader, err
}

func (c *Compresser) UseLzma2Reader() (io.Reader, error) {
	reader2, err := lzma.NewReader2(c.inFile)
	if err != nil {
		return nil, err
	}
	return reader2, err
}

func (c *Compresser) UseZlibReader() (io.Reader, error) {
	reader, err := zlib.NewReader(c.inFile)
	return reader, err
}

func (c *Compresser) UseLz4Reader() (io.Reader, error) {
	reader := lz4.NewReader(c.inFile)
	return reader, nil
}

func (c *Compresser) UseZipReader() (io.Reader, error) {
	zipFile, err := zip.OpenReader(c.inFile.Name())
	if err != nil {
		return nil, err
	}
	var reader io.Reader
	for _, innerFile := range zipFile.File {
		info := innerFile.FileInfo()
		if info.IsDir() {
			err = fmt.Errorf("the compressed file %s should not be a folder", info.Name())
			return nil, err
		}
		srcFile, err := innerFile.Open()
		if err != nil {
			return nil, err
		}
		//defer srcFile.Close()
		reader = srcFile
		break
	}
	return reader, err
}

func (c *Compresser) WithMode(mode CompressMode) (*Compresser, error) {
	var reader io.Reader
	var err error
	var modStr string

	switch mode {
	case ZipMode:
		modStr = "ZIP"
		reader, err = c.UseZipReader()
	case LzoMode:
		modStr = "LZO"
		reader, err = c.UseLzoReader()
	case SnappyMode:
		modStr = "SNAPPY"
		reader, err = c.UseSnappyReader()
	case ZlibMode:
		modStr = "ZLIB"
		reader, err = c.UseZlibReader()
	case Lz4Mode:
		modStr = "LZ4"
		reader, err = c.UseLz4Reader()
	case ZstdMode:
		modStr = "ZSTD"
		reader, err = c.UseZstdReader()
	case Lzma2Mode:
		modStr = "LZMA2"
		reader, err = c.UseLzma2Reader()
		/*case FlateMode:
		modStr="FLATE"
		writer,err = c.UseFlateWriter(fmt.Sprintf("%s.flate",c.inFile.Name()))*/

	}

	c.reader = reader
	c.modeStr = modStr
	return c, err
}

// Decompress 启动压缩 并计算时间,压缩前后文件大小
func (c *Compresser) Decompress() {
	n, err := io.Copy(c.ouFile, c.reader)
	if err != nil {
		panic(err)
	}
	fmt.Println(n)

}

func UseSnappyReader(reader io.Reader) (io.Reader, error) {
	return snappy.NewReader(reader), nil
}

func UseZstdReader(reader io.Reader) (io.Reader, error) {
	newReader, err := zstd.NewReader(reader)
	if err != nil {
		return nil, err
	}
	return newReader, err
}

func UseLzoReader(reader io.Reader) (io.Reader, error) {
	newReader, err := lzo.NewReader(reader)
	if err != nil {
		return nil, err
	}
	return newReader, err
}

func UseLzma2Reader(reader io.Reader) (io.Reader, error) {
	reader2, err := lzma.NewReader2(reader)
	if err != nil {
		return nil, err
	}
	return reader2, err
}

func UseZlibReader(reader io.Reader) (io.Reader, error) {
	newReader, err := zlib.NewReader(reader)
	if err != nil {
		return nil, err
	}
	return newReader, err
}

func UseLz4Reader(reader io.Reader) (io.Reader, error) {
	newReader := lz4.NewReader(reader)
	return newReader, nil
}

func UseZipReader(reader io.ReaderAt, size int64) (io.Reader, error) {
	r, err := zip.NewReader(reader, size)
	if err != nil {
		panic(err)
	}
	f, err := r.File[0].Open()
	if err != nil {
		panic(err)
	}
	return f, err
}

func WithMode(mode CompressMode, reader io.Reader) (io.Reader, error) {
	switch mode {
	case ZipMode:
		buff := bytes.NewBuffer([]byte{})
		size, err := io.Copy(buff, reader)
		if err != nil {
			return nil, err
		}
		reader := bytes.NewReader(buff.Bytes())
		return UseZipReader(reader, size)
	case LzoMode:
		return UseLzoReader(reader)
	case SnappyMode:
		return UseSnappyReader(reader)
	case ZlibMode:
		return UseZlibReader(reader)
	case Lz4Mode:
		return UseLz4Reader(reader)
	case ZstdMode:
		return UseZstdReader(reader)
	case Lzma2Mode:
		return UseLzma2Reader(reader)
	default:
		return nil, errors.New("wrong compression type")
	}

}
