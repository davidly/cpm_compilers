ntvcm Pascal48 %1

rem pasopt just goes into an infinite loop writing to the output file
rem ntvcm pasopt %1.SRC

ntvcm asmbl main,%1/rel

rem /e means link. /g means link and run
ntvcm link %1 /n:%1 /e

ntvcm -c -p %1




