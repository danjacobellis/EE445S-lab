# Lab 1. Overview of Hardware and Software Tools

## Aim of the experiment

The aim of the experiment is to familiarize you with the following:

1. STM32H735G Discovery Kit
2. STM32CubeIDE
3. MATLAB

## Reading assignment

* [Lab Primer][1]

* Digital Signal Processing using Arm Cortex-M based Microcontrollers by Cem Ünsalan, M. Erkin Yücel, H. Deniz Gürhan.
    * Chapter 1, sections 1-3
    * Chapter 5, sections 1-5
    * Chapter 10, sections 1-3

* Software Receiver Design by C. Richard Johnson, Jr., William A. Sethares and Andrew Klein
	* Chapter 1
	
* Course reader
	* Lecture 0 slides on [Introduction][3]

## Lab 1 instructions

Complete the following exercises during your lab section. Include your results in the lab report.

If you are unfamiliar with a particular MATLAB function, type `doc <function>`  or `help <function>` in the MATLAB command window.

### DSP in MATLAB

Since these exercises are intended to teach the basics of MATLAB, some possible solutions are provided.

1.  Create a vector `t` representing the time variable with range of one second and sampling period of of $T_s = 0.001$ sec. One way to create a vector of evenly spaced numbers in MATLAB is with the `:` operator. Alternatively, you can use the `linspace` function.

    *Solution 1:* 
    ```
    t = 0:0.001:1;
    ```
    *Solution 2:* 
    ```
    t = linspace(0,1,1001);
    ```

2.  Create a plot that approximates the continuous time signal $x(t)=sin(2 \pi t)$ for $0 \leq t \leq 1$, using the `plot` function.

    *Solution 1:*
    ```
    x = @(t) sin(2*pi*t);
    plot(t,x(t));
    ```

    *Solution 2:*
    ```
    xt = sin(2*pi*t);
    plot(t,xt);
    ```


3.  Label the plot using the `xlabel`, `ylabel`, and `title` functions.

    *Solution:*
    ```
    xlabel('Time [seconds]');
    ylabel('Signal Amplitude x(t)');
    title('x(t)=sin(t)');
    ```

4.  Obtain the value of the signal at time t = 0.32 seconds.

    *Solution 1:*
    ```
    x(0.32)
    ```

    *Solution 2:*
    ```
    [~, ind] = min(abs(t-0.32));
    xt(ind)
    ```

5.  Sample the signal at every 0.008-sec.

    *Solution 1:* 
    ```
    xn = x(t(1:8:end));
    ```
    
    *Solution 2:* 
    ```
    xn = downsample(xt,8);
    ```

6.  Overlay the sampled signal on your continous plot using the `stem` function

    *Solution:*
    ```
    tn = t(1:8:end);
    hold all;
    stem(tn,xn);
    ```
    
**Include the code for steps 1-6 in your lab report along with the figure you generated.**
    
### Using the STM32H735G discovery kit and starter code

In order for you to get started programming the board, we have created a sample project which passes a signal from the input jack to the output jack (this is known as a talkthrough.) Additionally, the spectrum of the input signal is visualized on the LCD.

1. Follow the [instructions in the setup guide][4] to import the starter code and program the board..

2. Connect the blue input jack on the board to the signal generator set to a 1kHz sine wave.

3. Connect the green output jack on the board to the oscilloscope.

4. Configure the oscilloscope and verify the that the signal appears as expected.

5. Locate the `process_left_channel` function in `lab.c`. Change the behavior from a talkthrough $f(x[n]) = x[n]$ to a squaring function $f(x[n]) = {(x[n])}^2$ by modifying the line `output_sample = input_sample;` Rerun the program and observe the result on the oscilloscope.

6. At the end of the `process_left_sample` function in `lab.c`, locate the line `return output_sample;`. Put a breakpoint at this line.

7. Allow the program to continue until it stops at the breakpoint. Add a watch expression for the variable `elapsed_cycles` and record the value. **Include this measurement in your lab report.**

## Lab report contents

Be sure to include everything listed in this section when you submit your lab report.

### I. Results from lab exercise

1. DSP in MATLAB

2. Using the STM32H735G discovery Kit and starter code

### II. Assignment questions

1. What is aliasing? How do you manage aliasing in DSP applications?

2. Draw a block diagram of a generic DSP system and a talk-through system.

3. How are 32-bit floating-point results saved on the ARM Cortex-M7 processor? Explain briefly the IEEE single-precision floating-point format.

4. Give an example (such as one or more lines of C code) that would result in the processor using IEEE single-precision floating point for an operation.

5. How can you estimate the number of clock cycles required to execute a section of code on the STM32 board?

[1]:primer.md
[2]:https://www.arm.com/resources/ebook/digital-signal-processing
[3]:http://users.ece.utexas.edu/~bevans/courses/realtime/lectures/00_Introduction/lecture0.pptx
[4]:stm32h735g.md