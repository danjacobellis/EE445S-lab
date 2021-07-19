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

## Lab 1 Instructions

Complete the following exercises during your lab section. Include your results in the lab report.

If you are unfamiliar with a particular MATLAB function, type `doc <function>`  or `help <function>` in the MATLAB command window.

### DSP in MATLAB

Since these exercises are intended to teach the basics of MATLAB, the solutions are provided.

1.  Create a vector `t` representing the continuous time variable with range of one second and sampling period of of $T_s = 0.001$ sec. Please exclude the last data point, i.e., the end point becomes 1-1/fs. One way to create a vector of evenly spaced numbers in MATLAB is with the `:` operator. Alternatively, you can use the `linspace` function.

    *Solution 1:* 
    ```
    t = 0:0.001:0.999;
    ```
    *Solution 2:* 
    ```
    t = linspace(0,0.999,1000);
    ```

2.  Create a plot that approximates the continuous time signal $x(t)=sin(t)$ for $0 < t < 1$, using the `plot` function.

    *Solution:*
    ```
    xt = sin(t);
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
    sin(0.32)
    ```

    *Solution 2:*
    ```
    [~, ind] = min(abs(t-0.32));
    x(ind);
    ```

5.  Sample the signal at every 0.008-sec.

    *Solution 1:* 
    ```
    xn = x(1:8:end);
    ```
    
    *Solution 2:* 
    ```
    xn = downsample(x,8);
    ```

6.  Overlay the sampled signal on your continous plot using the `stem` function

    *Solution:*
    ```
    tn = t(1:8:end);
    hold all;
    stem(tn,xn);
    ```
    
### Using the STM32H735G Discovery Kit and Starter code

In order for you to get started programming the board, we have created a sample talkthough project.

1. Follow the [instructions in the setup guide][4] to program the board and import the starter code.

2. Connect the blue input jack on the board to the signal generator set to a 1kHz sine wave.

3. Connect the green output jack on the board to the oscilloscope.

4. Configure the oscilloscope and verify the that the signal appears as expected.

5. Locate the `process_left_channel` function in `lab.c`. Change the behavior from a talkthrough (output=input) to a squaring function (output = input * input.) Rerun the program and observe the result on the oscilloscope.

6. in `lab.c`, put a breakpoint on the line `return output_sample;` at the end of the `process_left_sample` function. 

7. Allow the program to continue until it stops at the breakpoint. Add a watch expression for the variable `elapsed_cycles` and record the value. **Include this measurement in your lab report.**


## Lab Report Contents

Be sure to include everything listed in this section when you submit your lab report.

### I. Results from Lab Exercise

1. DSP in MATLAB

2. Using the STM32H735G Discovery Kit and Starter code

### II. Assignment Questions

1. What is aliasing? How do you manage aliasing in DSP applications?

2. Draw a block diagram of a generic DSP system and a talk-through system.

3. Draw a diagram (specific to the STM32 board) that shows the movement of data in the provided talkthrough program. Be sure to include at least the following elements: (1) input jack, (2) WM8994 audio codec, (3) the STM32 microcontroller's serial audio interface (SAI), (4) main memory, and (5) output jack.

3. How are 32-bit floating-point results saved on the ARM Cortex-M7 processor? Explain briefly the IEEE single-precision floating-point format.

4. Give an example (such as one or more lines of C code) that would result in the processor using IEEE single-precision floating point for an operation.

5. How can you estimate the number of clock cycles required to execute a section of code on the STM32 board?	

[1]:primer.md
[2]:https://www.arm.com/resources/ebook/digital-signal-processing
[3]:http://users.ece.utexas.edu/~bevans/courses/realtime/lectures/00_Introduction/lecture0.pptx
[4]:stm32h735g.md