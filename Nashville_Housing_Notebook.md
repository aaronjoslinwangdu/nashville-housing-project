# Nashville Housing Project
---
By Aaron Joslin-Wangdu on 9/17/2021


## Goal
---
The goal for this project was to investigate the differences in the following data from 2013 to 2016:
1. How many sales there were in each city in the Nashville area?
2. How do sales numbers differ for different land type uses?
3. What is the average sale price for each city?
4. How are the sale prices distributed for each city?
5. Are there 'hot' times that people are buying houses each year and does the city affect this?


## The Data
---
The dataset used in this project is the publicly available [Nashville Housing Dataset](https://www.kaggle.com/tmthyjames/nashville-housing-data) that includes data about property sales in the greater Nashville, Tennessee area. The raw data as well as the cleaned data are located in the [data folder](https://github.com/aaronjoslinwangdu/nashville-housing-project/tree/main/data).


## Preparation
---
The raw dataset was imported into a local database using Microsoft SQL Server Management and all of the cleaning was done there. Supplementary notes and the functions used to clean the data can be located in the [Data_Cleaning_Portfolio_Project_Queries.sql file](https://github.com/aaronjoslinwangdu/nashville-housing-project/blob/main/Data_Cleaning_Portfolio_Project_Queries.sql).

After doing this, the .csv file was imported into Google Sheets and a was filtered to hide rows with data (values in incorrect columns, irrelevant/unusable data, etc.) and the resulting file can be viewed [here](https://github.com/aaronjoslinwangdu/nashville-housing-project/blob/main/data/Nashville_Housing_Data_Cleaned_v2.csv), and will be used in the following cells.

## Analysis
---
We will analyze this data using Python. The packages that were used are: pandas.

First, import all of the necessary packages


```python
import pandas as pd
import numpy as np
import datetime
```

Next, create a dataframe by reading the values in the [.csv](https://github.com/aaronjoslinwangdu/nashville-housing-project/blob/main/data/Nashville_Housing_Data_Cleaned.csv) file.


```python
#header_list=['UniqueID''ParcelID','LandUse','SalePrice','LegalReference','SoldAsVacant','Acreage','LandValue','BuildingValue','TotalValue','YearBuilt','Bedrooms','FullBath','HalfBath','SaleDateConverted','PropertySplitAddress','PropertySplitCity','OwnerSplitAddress','OwnerSplitCity','OwnerSplitState']
#df = pd.read_csv('Nashville_Housing_Data_Cleaned.csv',dtype={'UniqueID':int,'ParcelID':str,'LandUse':str,'SalePrice':int,'LegalReference':str,'SoldAsVacant':str,'Acreage':float,'LandValue':float,'BuildingValue':float,'TotalValue':float,'YearBuilt':int,'Bedrooms':float,'FullBath':int,'HalfBath':int,'SaleDateConverted':str,'PropertySplitAddress':str,'PropertySplitCity':str,'OwnerSplitAddress':str,'OwnerSplitCity':str,'OwnerSplitState':str})
df = pd.read_csv('Nashville_Housing_Data_Cleaned_v2.csv')

#rename a column because it had a space in the name
df = df.rename(columns={"UniqueID ":"UniqueID"})

#convert SaleDateConverted column to a date format
df['SaleDateConverted'] = pd.to_datetime(df['SaleDateConverted'])

#show table info
df.info()
```

    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 56369 entries, 0 to 56368
    Data columns (total 20 columns):
     #   Column                Non-Null Count  Dtype         
    ---  ------                --------------  -----         
     0   UniqueID              56369 non-null  int64         
     1   ParcelID              56369 non-null  object        
     2   LandUse               56369 non-null  object        
     3   SalePrice             56369 non-null  int64         
     4   LegalReference        56369 non-null  object        
     5   SoldAsVacant          56369 non-null  object        
     6   Acreage               25965 non-null  float64       
     7   LandValue             25965 non-null  float64       
     8   BuildingValue         25965 non-null  float64       
     9   TotalValue            25965 non-null  float64       
     10  YearBuilt             24117 non-null  float64       
     11  Bedrooms              24111 non-null  float64       
     12  FullBath              24229 non-null  float64       
     13  HalfBath              24098 non-null  float64       
     14  SaleDateConverted     56369 non-null  datetime64[ns]
     15  PropertySplitAddress  56369 non-null  object        
     16  PropertySplitCity     56369 non-null  object        
     17  OwnerSplitAddress     25965 non-null  object        
     18  OwnerSplitCity        25965 non-null  object        
     19  OwnerSplitState       25965 non-null  object        
    dtypes: datetime64[ns](1), float64(8), int64(2), object(9)
    memory usage: 8.6+ MB
    

---
See what the first ten rows of the dataframe look like.


```python
testView = df.head(10)
testView
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>UniqueID</th>
      <th>ParcelID</th>
      <th>LandUse</th>
      <th>SalePrice</th>
      <th>LegalReference</th>
      <th>SoldAsVacant</th>
      <th>Acreage</th>
      <th>LandValue</th>
      <th>BuildingValue</th>
      <th>TotalValue</th>
      <th>YearBuilt</th>
      <th>Bedrooms</th>
      <th>FullBath</th>
      <th>HalfBath</th>
      <th>SaleDateConverted</th>
      <th>PropertySplitAddress</th>
      <th>PropertySplitCity</th>
      <th>OwnerSplitAddress</th>
      <th>OwnerSplitCity</th>
      <th>OwnerSplitState</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>56635</td>
      <td>093 13 0D 094.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>330000</td>
      <td>20161104-0117077</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-27</td>
      <td>700 12TH  AVE S</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>56634</td>
      <td>093 13 0D 056.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>320000</td>
      <td>20161031-0114730</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-26</td>
      <td>700 12TH  AVE S</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2</th>
      <td>56633</td>
      <td>093 13 0D 048.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>742000</td>
      <td>20161010-0106889</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-04</td>
      <td>700 12TH  AVE S</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>3</th>
      <td>56632</td>
      <td>093 13 0D 044.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>338000</td>
      <td>20161101-0115186</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-25</td>
      <td>700 12TH  AVE S</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>4</th>
      <td>56631</td>
      <td>093 13 0B 274.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>210000</td>
      <td>20161007-0106599</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-06</td>
      <td>320 11TH  AVE S</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>5</th>
      <td>56630</td>
      <td>093 11 0B 012.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>275000</td>
      <td>20161018-0109872</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-14</td>
      <td>464 2ND  AVE S</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>6</th>
      <td>56629</td>
      <td>093 09 0C 262.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>397000</td>
      <td>20161006-0105844</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-03</td>
      <td>1212 LAUREL  ST</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>7</th>
      <td>56628</td>
      <td>093 09 0C 105.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>543000</td>
      <td>20161014-0108683</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-11</td>
      <td>1212 LAUREL  ST</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>8</th>
      <td>56627</td>
      <td>093 09 0C 090.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>589900</td>
      <td>20161114-0119528</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-21</td>
      <td>1212 LAUREL  ST</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>9</th>
      <td>56626</td>
      <td>093 06 0A 004.00</td>
      <td>RESIDENTIAL CONDO</td>
      <td>325000</td>
      <td>20161027-0113759</td>
      <td>No</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>2016-10-20</td>
      <td>301 DEMONBREUN  ST</td>
      <td>NASHVILLE</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>



From the previous two cells we can see that many rows are missing data in columns including **Acreage**, **LandValue**, and **FullBath**. However, these columns won't be used in our analysis and the key columns for this project: **SalePrice**, **PropertySplitCity**, and **SaleDateConverted** are fully populated.


```python
df.LandUse.unique()
```




    array([nan, 'NASHVILLE', 'ANTIOCH', 'HERMITAGE', 'OLD HICKORY', 'MADISON',
           'GOODLETTSVILLE', 'BRENTWOOD', 'WHITES CREEK', 'JOELTON',
           'MOUNT JULIET', 'BELLEVUE', 'NOLENSVILLE'], dtype=object)




```python
df.LandUse.unique()
```




    array(['RESIDENTIAL CONDO', 'CONDOMINIUM OFC  OR OTHER COM CONDO',
           'VACANT RESIDENTIAL LAND', 'SINGLE FAMILY', 'ZERO LOT LINE',
           'DUPLEX', 'DORMITORY/BOARDING HOUSE', 'QUADPLEX', 'TRIPLEX',
           'SPLIT CLASS', 'RESIDENTIAL COMBO/MISC', 'RESTURANT/CAFETERIA',
           'FOREST', 'DAY CARE CENTER', 'MOBILE HOME', 'CHURCH',
           'NON-PROFIT CHARITABLE SERVICE', 'VACANT RURAL LAND', 'GREENBELT',
           'MORTUARY/CEMETERY', 'VACANT COMMERCIAL LAND', 'NIGHTCLUB/LOUNGE',
           'OFFICE BLDG (ONE OR TWO STORIES)', 'VACANT RESIENTIAL LAND',
           'PARKING LOT', 'PARSONAGE', 'TERMINAL/DISTRIBUTION WAREHOUSE',
           'SMALL SERVICE SHOP', 'APARTMENT: LOW RISE (BUILT SINCE 1960)',
           'ONE STORY GENERAL RETAIL STORE', 'LIGHT MANUFACTURING',
           'CLUB/UNION HALL/LODGE', 'CONVENIENCE MARKET WITHOUT GAS', 'CONDO',
           'VACANT RES LAND', 'VACANT ZONED MULTI FAMILY',
           'STRIP SHOPPING CENTER'], dtype=object)




```python

```


```python

```


```python

```


```python

```


```python

```


```python

```

## Visualizations
---
figures here!



```python

```


```python

```


```python

```


```python

```


```python

```

## Difficulties
---
difficulties here!


```python

```


```python

```


```python

```


```python

```


```python

```


```python

```


```python

```


```python

```

## Conclusion
---
observations and recommendations here


```python

```
