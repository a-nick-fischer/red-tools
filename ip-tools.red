ip-convert: function [
    {Converts between IP-Address representations. Input format
    is recognised automaticly.}

    data    "The address to convert."
    format  "The format to convert to. One of: 'ddr 'cidr 'hex 'bin"
][
    ;; First we convert the given format to its binary representation
    
    ;; Create a string which will hold the 32 bytes of the binary representation
    buffer: make string! 32

    ;; Lookup the type of the data and convert it to a binary string
    switch type?/word data [

        ;; CIDR
        integer! [
            ;; Writes as many as 'data' "1" to buffer, and pads it with "0"
            buffer: pad/with append/dup buffer "1" data 32 #"0"
        ]

        ;; It is already a binary string
        string! [
            buffer: data
        ]

        ;; Hex representation (Yes, Reds binary! datatype should be called hex! instead)
        binary! [
            buffer: enbase/base data 2
        ]

        ;; The DDR representation
        tuple! [
            ;; Repeat for all 4 octets of the IP
            repeat index 4 [
                ;; Convert the octet to a binary representation
                b: enbase/base (to-binary pick data index) 2
                ;; Append the first 8 bytes of the binary octet to the buffer
                buffer: append buffer at b ((length? b) - 7)
            ]
        ]
    ]

    ;; Lookup the format we want to convert to
    switch format [
        ddr [
            ;; Define our charset for parsing and buffer
            bin: charset {10}
            tup: make block! 4
            ;; Parse the binary buffer, converting every 8 bits to their integer 
            ;; representations and writing them to the buffer
            parse buffer [
                any [
                    copy s [8 bin] (append tup to-integer debase/base s 2)
                ]
            ]
            ;; Return a tuple generated from the buffer
            make tuple! tup
        ]

        cidr [
            ;; Check if the binary buffer is a valid subnetmask
            check-subnetmask* buffer
            ;; Substract the position of first "0" in the binary buffer from 32
            32 - either none? res: length? find buffer "0" [0][res]
        ]

        hex [
            debase/base buffer 2
        ]

        bin [
            buffer
        ]
    ]
]

check-subnetmask*: function [
    "Throws an error if the given subnetmask is not valid"
    mask
][
    unless valid-subnetmask? mask [
        cause-error 'user 'message reduce [rejoin ["Invalid Subnetmask: " data]]
    ]
]

valid-subnetmask?: function [
    "Returns if the given IP address is a valid subnetmask"
    mask
][
    ;; Convert the address to a binary string and find the position of the first "0"
    bin: find ip-convert mask 'bin "0"
    ;; Return 'true' if the address didn't contain a "0" or if it doesn't contain a "1" after the first "0"
    ;; ('not none?' was added to avoid this function to return 'none' instead of 'false')
    not none? any [none? bin none? find bin "1"]
]

usable-adresses-of: function [
    "Returns the number of host-addresses allowed by the given subnetmask"
    subnetmask
][
    ;; Substract the given subnetmasks CIDR from 32, power it by 2, and substract 2 
    ;; (to exclude the network address and the broadcast address)
    ;; If it's lower than 0 (in case of the subnetmask 255.255.255.255) return 0
    max 2 ** (32 - ip-convert subnetmask 'cidr) - 2 0
]

wildcard-of: function [
    "Return the wildcard address of this subnetmask"
    subnetmask
][
    ;; Substract the given submasks CIDR from 32, to obtain the host-bit count
    host-bits: 32 - ip-convert subnetmask 'cidr
    ;; Create a buffer for the generated address
    buffer: make string! 32
    ;; Append as many "1" to the buffer as host bits, pad with "0" from left to 32
    ;; and convert it to DDR
    ip-convert pad/left/with append/dup buffer "1" host-bits 32 #"0" 'ddr
]