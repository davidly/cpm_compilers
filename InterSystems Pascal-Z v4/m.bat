ntvcm Pascal48 %1

rem pasopt requires some uninitialized RAM to be non-zero to work. It depends on some other
rem app having run to initialize that memory. It's a byte at BDOS - 30eh, which is 0fbeeh
rem for NTVCM, which fills this byte for this app.
ntvcm pasopt %1.SRC

ntvcm asmbl main,%1/rel

rem /e means link. /g means link and run
ntvcm link %1 /n:%1 /e

ntvcm -c -p %1




