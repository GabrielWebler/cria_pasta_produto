$caminho = "C:\teste-permit\pasta"
$f = new-object System.IO.FileStream $caminho\test.dat, Create, ReadWrite
$f.SetLength(1GB)
$f.Close()
