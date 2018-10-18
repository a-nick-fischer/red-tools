### Red-Tools
A collection of small, maybe useful tools and mini-libraries written in Red.

---
#### ip-tools.red
A mini library for working with `IPv4` addresses and subnetmasks.
Examples:
```rebol
; Convert /24 CIDR mask into Dotted Decimal Notation
>> ip-convert /24 'ddn
== 255.255.255.0

; Convert DDN IP into binary (as a string!)
>> ip-convert 192.168.1.34 'bin
== "11000000101010000000000100100010"

; Why is the result of the above conversion a string!?
; - because Red's binary! datatype is displayed as a hex number:
>> ip-convert 192.168.1.34 'hex
== #{C0A80122}

; Check subnetmasks
>> valid-subnetmask? 17 ; Same as /17
== true
>> valid-subnetmask? 10.0.0.5
== false

; Get the amount of host IP's of a subnetmask
>> usable-adresses-of /16
== 65534

; Get the wildcard of a subnetmask
>> wildcard-of 255.255.255.0
== 0.0.0.255
```
