# Lab 2. Generating Cosine and Sine Waves

## Aim of the experiment

The aim of this experiment is to

* explore the design tradeoffs in signal quality vs. runtime complexity in computing amplitude values of sinusoidal signals.

Sinusoidal waveforms will be computed in discrete time, plotted, and played as audio signals.

## Reading assignment

* Digital Signal Processing using Arm Cortex-M based Microcontrollers by Cem Ünsalan, M. Erkin Yücel, H. Deniz Gürhan.
    * Chapter 2, sections 1-5
    * Chapter 3, sections 1-7

* Software Receiver Design by C. Richard Johnson, Jr., William A. Sethares and Andrew Klein
	* Chapter 1
    
* Course reader
    * Lecture 1 slides on [Generating Sinusoidal Signals][1]
    
## Lab 2 instructions: Week 1

### Sinusoidal generation using math library and phase accumulation

### Sinusoidal generation using difference equation

## Lab 2 instructions: Week 2

### Sinusoidal generation using lookup table

## Lab report contents

Be sure to include everything listed in this section when you submit your lab report.

### I. Results from lab exercise

1. Sinusoidal generation using math library and phase accumulation

2. Sinusoidal generation using difference equation

3. Sinusoidal generation using lookup table

### II. Assignment questions

1. Explain (mathematically) what happened when 6 kHz & 7 kHz sine waves were generated for a sample rate of 8 kHz.

2. Why is the scaling factor necessary? What would happen if the scaling factor was left out?

3. When generating a sinusoid with a sampling rate of 8kHz, how many cycles would occur between samples? Assume that the processor is running at 500 MHz. 

4. Repeat the previous question for a sampling rate of 192 kHz.

5. Look at the measurement you obtained for the number of clock cycles required to execute the math library sin function. Compare this number to the answers obtained in the previous two question. What do these numbers tell you about the feasibility of the math library method for generating sinusoids as the sampling rate increases?
    
[1]:http://users.ece.utexas.edu/~bevans/courses/realtime/lectures/01_Sinusoids/lecture1.ppt