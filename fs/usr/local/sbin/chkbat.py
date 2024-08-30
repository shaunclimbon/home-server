# This script checks backup battery levels and will shutdown the system as levels get low.
# Based on an APC Back-UPS Pro BR 1000/1350/1500 MS, but could work for other APC models.

import re
import subprocess
import sys

tonbat = subprocess.check_output("apcaccess -up TONBATT", shell=True)
if int(tonbat) == 0:
#	print("On line voltage")
	sys.exit(0)

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
#timeleft = 1
if timeleft > 10:
	print("Still have time to kill")
	sys.exit(0)

# At 10 & 5 min markers start dealing with VM shutdowns
if timeleft < 10 and timeleft > 2.5:
	# Check for running VMs
	vms = subprocess.check_output("virsh list", shell=True)
	res = re.findall(r"^\s\d\s*(\S+)", vms, re.MULTILINE)
	if not(res):
		print("No VMs running")
		sys.exit(0)    
   
	# Less than 10 mins left so commence graceful VM shutdown
	if timeleft < 10 and timeleft > 5:
		for vm in res:
			print("shutting down " + vm)
			subprocess.call("virsh shutdown " + vm, shell=True)
   
	# If less than 5 mins left force VM shutdown
	if timeleft < 5:
		for vm in res:
			print("killing " + vm)
			subprocess.call("virsh destroy " + vm, shell=True)
			
	sys.exit(0)

# If less than 2-1/2 mins left shutdown system
if timeleft < 2.5:
	print("shutting down system")
	subprocess.call("shutdown now", shell=True)


