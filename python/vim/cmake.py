import vim

def flags(filetype="cpp"):
  return vim.eval('b:cmake_flags["' + filetype + '"]')
