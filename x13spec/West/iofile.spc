series{
  title = "iofile"
  file = "/var/folders/d9/5v776z717cdc1t6_xz7wbch40000gn/T//Rtmprds6LD/x1311e70116921f6/iofile.dta"
  format = "datevalue"
  period = 12
}

transform{
  function = auto
  print = aictransform
}

regression{
  aictest = (td easter)
}

outlier{

}

automdl{
  print = bestfivemdl
}

x11{
  save = (d10 d11 d12 d13 d16 e18)
}

estimate{
  save = (model estimates residuals)
}

spectrum{
  print = qs
}
