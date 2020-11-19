import re
import subprocess
import sys

tonbat = subprocess.check_output("apcaccess -up TONBATT", shell=True)
if int(tonbat) == 0:
	print("On line voltage")
#	sys.exit(0)

#charge = subprocess.check_output("apcaccess -up BCHARGE", shell=True)
#print(type(output))
#res = re.search(r"^BCHARGE\s*:\s([\d|\.]+)", output, re.MULTILINE)
#if res:
#	print(res.group(0))
#	print(res.group(1))
#else:
#	print("ERROR")
#	sys.exit(0)	

# Time left in mins
timeleft = float(subprocess.check_output("apcaccess -up TIMELEFT", shell=True))
if timeleft > 10:
	print("Still have time to kill")
#	sys.exit(0)

# If less than 5 mins left force shutdown
if timeleft < 5:
	#TODO...
	subprocess.run("virsh destroy " + vm, shell=True)
	sys.exit(0)

# Less than 10 mins left so commence graceful shutdown sequence
vms = subprocess.check_output("virsh list", shell=True)
res = re.search(r"^\s\d\s*(\w+)", vms, re.MULTILINE)
if res == None:
	print("ERROR")
	sys.exit(0)

#print(res.group(0))
#print(res.group(1)) 
for vm in res.groups():
	print("shutting down " + vm)
	subprocess.call("virsh shutdown" + vm, shell=True)
