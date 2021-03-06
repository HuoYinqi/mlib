REM Execute the test suite for Microsoft Visual Studio
REM
REM Load Micosoft Visual Studio environement file.
IF EXIST "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
)
IF EXIST "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64
)

REM Remove previous results
DEL *.log *.dat

REM List the expected failure (compiler internal error)
set "expectedFailure1=test-msnapshot.c"
set "expectedFailure2=test-mtuple.c"

echo "Compiler full version:"
cl /Bv

echo " "

REM Perform for each test
for %%f in (test-*.c) do (
    echo Testing %%f
    REM Copy the test file as a C++ file as CL.EXE only support C++ file
    copy %%f test.cpp
    if ERRORLEVEL 1 EXIT /B 1
    REM Compile the test suite
    REM /Zc:preprocessor is mandatory to have a compliant preprocessor
    REM /Zc:__cplusplus is needed to report the real value of __cplusplus, so that M*LIB uses the C++ atomic, and not its emulation.
    echo Compiling %%f
    cl.exe /I.. /O2 /std:c++14 /Zc:__cplusplus /Zc:preprocessor test.cpp > %%f.log 2>&1 
    if ERRORLEVEL 1 ( 
        echo *** BUILD ERROR for %%f *** >> %%f.log
        type %%f.log 
        if /i "%%f" NEQ "%expectedFailure1%" if /i "%%f" NEQ "%expectedFailure2%" EXIT /B 1
        )
    REM Execute it
    echo Running %%f
    test.exe >> %%f.log 2>&1 
    if ERRORLEVEL 1 (
        echo *** RUNTIME ERROR for %%f ***  >> %%f.log
        type %%f.log 
        if /i "%%f" NEQ "%expectedFailure%" EXIT /B 1
    ) ELSE (
        echo Test OK for %%f  >> %%f.log
    )
    type %%f.log
)
echo "All tests passed (except %expectedFailure%)"
exit /B 0
