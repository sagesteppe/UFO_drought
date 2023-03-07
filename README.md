# UFO drought

There is little consensus on what quantifies ecological drought, i.e. how much drier than normal does it need to be for a locality to be in drought? While we avoid these questions, we do calculate the a very common metric of drought Standardized Precipitation Evapotranspiration Index (SPEI). Some discussion of the advantages of both, largely recapitulated from better sources is also done.

<div align="center">
  
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



<div align="center">

Variables to calculate Potential Evaporation via the Penman-Montieth equation 

|            Variable            |           Source            |
|  :------------------------:    |     :---------------:       |
|    precipitation sum (mm)      |       GridMET  (pr)         |
|      mean max temp (ºC)        |       GridMET (tmmx)        |
|      mean min temp (ºC)        |       GridMET (tmmn)        |
|      mean rel. humidity        | $(RH_{max} + RH_{min}) /2$  |
|    mean wind speed (km h-1)    |       GridMET (vs)          |        
|     mean sun hours (hours)     |     r.sunhours ('sunhour)   |
|  mean solar radiation (MJ-m-d) |       r.sun ('beam_rad')    |
|   mean cloud cover (percent)   |     Wilson, EarthEnv        |
|     elevation in meters        |       EarthEnv 90m          |
  
**Note all of these values are over a month**

</div>

The metrics: 1) $T_{min}$, 2) $T_{max}$, 3) mean sun hours, 4) and elevation will be used
collectively to calculate evapotranrespiration using the Penman equation. If you cannot
locate these variables than you can just supply Tmin and Tmax to the Thornthwaite or Hargreaves equation.
