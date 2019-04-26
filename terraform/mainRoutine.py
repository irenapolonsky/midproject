#!/usr/bin/python


from python_terraform import *
t = Terraform()
#return_code, stdout, stderr = t.<cmd_name>(*arguments, **options)
return_code, stdout, stderr = t.plan()
print(stdout)


