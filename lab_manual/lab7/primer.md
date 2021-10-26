# Lab 7 Primer

# Speech

[Source-filter model][1]

## Simple model of larynx

```
fs = 48000;
f0 = 160;
N = round(0.5*fs/f0);
x = repmat([gausswin(N,3);zeros(N,1)],[500,1]);
x = x - mean(x);
soundsc(x,fs);
```

## Fundamental frequency estimation

[Pitch detection][2]

## Modeling the vocal tract

[Least mean squares filter][3]

[1]:https://en.wikipedia.org/wiki/Source–filter_model
[2]:https://en.wikipedia.org/wiki/Pitch_detection_algorithm
[3]:https://en.wikipedia.org/wiki/Least_mean_squares_filter