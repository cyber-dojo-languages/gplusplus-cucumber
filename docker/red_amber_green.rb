lambda { |stdout,stderr,status|
  output = stdout + stderr

  return :amber if /Error/.match(output)
  return :amber if /SyntaxError/.match(output)
  return :amber if /NameError/.match(output)
  return :amber if /^[.\-UAPF]*U[.\-UAPF]*$/.match(output)
  return :amber if /^[.\-UAPF]*A[.\-UAPF]*$/.match(output)
  return :red if /^[.\-UAPF]*P[.\-UAPF]*$/.match(output)
  return :red if /^[.\-UAPF]*F[.\-UAPF]*$/.match(output)
  return :green
}
