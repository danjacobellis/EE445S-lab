# Lab 4 Primer

Pseudo-random binary sequences are also known as pseudo-noise (PN) sequences because the sequences resemble noise. These binary sequences appear to be random but instead have structure. They have all frequencies present; i.e., there are no nulls in the magnitude spectrum.

![](img/PN_seq.svg)

## Applications of Pseudo-Random Binary Sequences

PN sequences are widely used to

* generate test, measurement and calibration signals
* generate training signals in communication systems
* scramble and descramble data in communication systems

### As a signal for test, measurement, and calibration
The first application is to use a PN sequence to estimate an impulse response of an unknown subsystem, e.g. the cascade of a source, empty chamber, and receiver in a biomedical instrument. Once the impulse response is known, calibration of the system can proceed by means of a linear time-invariant filter in the transmitter (known as a predistorter) or receiver (known as an equalizer) to compensate for the distortion in the subsystem.

### As a training signal
As a training signal, the PN sequence would be the digital data to be transmitted over the unknown communication channel. The receiver knows the bits that had been transmitted, and can use that knowledge to adapt receiver settings to improve communication performance (signal quality). The receiver can also estimate the impulse response of the communication channel if needed.

### Data scrambler/descrabler
In data scramblers, PN sequences are used to prevent long strings of 0's and 1's. For baseband transmission, during a long string of 0's or 1's, the primary frequency component in the signal would be at DC, and DC does not get passed by some communication channels (e.g. voiceband and acoustic channels). For bandpass transmission, during a long string of 0's or 1's, the primary frequency of the message signal (DC) would be upconverted to sit at the carrier frequency. This presents at least two problems:

* The receiver may have more difficulty for the receiver to lock onto the carrier frequency and phase
* The receiver will have greater difficulty performing symbol synchronization if the symbol synchronization algorithm uses frequency content at the transmission bandwidth's edges for the symbol timing estimate.

The primary application of PN sequences in lab #4 is for data scrambling and descrambling.

## Linear-feedback shift register (LFSR)

In lab #4, we will use a a Fibonacci LFSR to generate PN sequences. This structure shares many similarities to the tapped delay line for filtering.

![](img/Fibonacci_LFSR.svg)

The Fibonacci LFSR maintains an $m$-bit state. To generate an output of the PN sequence, some of the bits in the LFSR state are combined by addition modulo 2 (equivalent to and XOR operation). Then, to prepare for the next output, the states are shifted and the new