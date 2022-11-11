# UFO_drought

There seems to be little consensus on what quantifies ecological drought, i.e. how much drier than normal does it need to be for a locality to be in drought? While we avoid these questions, we do calculate the two most common metrics of drought the Palmer Drought Severity Index (PDSI), and Standardized Precipitation Evapotranspiration Index (SPEI). Some discussion of the advantages of both, largely recapitulated from better sources is also done.

<div align="center">
       PDSI Values Interpretation
|      Value      |   Interpretation    |
| :------------:  | :-----------------: |
|     > 4.0       |    extremely wet    |
|   3.0 to 3.99   |      very wet       |
|   2.0 to 2.99   |   moderately wet    |
|   1.0 to 1.99   |    slightly wet     |
|   0.5 to 0.99   | incipient wet spell |
|  0.49 to -0.49  |    near normal      |
|  -0.5 to -0.99  | incipient dry spell |
|  -1.0 to -1.99  |    mild drought     |
|  -2.0 to -2.99  |  moderate drought   |
|  -3.0 to -3.99  |   severe drought    |
|     < -4.0      |  extreme drought    |

         SPI Values Interpretation
|     Value       |    Interpretation       |
| :------------:  | :------------------:    |
|     > -0.5      |      near normal        | 
|  -0.5 to -0.7   |    Abnormally Dry       |
|  -0.8 to -1.2   |   Moderate Drought      |
|  -1.3 to -1.5   |    Severe Drought       |
|  -1.6 to -1.9   |    Extreme Drought      |
|    < -2.0       |  Exceptional Drought    |

*these table copied from a presentation by Brian Fuchs of the
National Drought Mitigation Center and University of Nebraska-Lincoln*

</div>



Variables required to calculate SPEI (using the SPEI package), via the
Penman equation

|           Variable            |        Source        |
| :------------------------:    |  :---------------:   |
|       precip sum (mm)         |     GridMET  (pr)    |
|   mean daily max temp (ºC)    |     GridMET (tmmx)   |
|   mean daily min temp (ºC)    |     GridMET (tmmn)   |
|       mean temp (ºC.)         |$T_{max} + T_{min} /2$|
|  mean wind speed (km h-1)     |     GridMET (vs)     |        
|    mean sun hours (hours)     |                      |
|   mean cloud cover (percent)  |   Wilson, EarthEnv   |
|    elevation in meters        |                      |

Note all of these values are monthly

The metrics: 1) $T_{min}$, 2) $T_{max}$, 3) mean sun hours, 4) and elevation will be used
collectively to calculate evapotranrespiration using the Penman equation. If you cannot
locate these variables than you can just supply Tmin and Tmax to the Thornthwaite or Hargreaves equation.
