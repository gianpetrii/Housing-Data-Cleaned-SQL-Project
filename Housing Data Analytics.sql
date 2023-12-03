/*

Cleaning Data in SQL

*/


Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- asi se ve ahora vs cuando convierta
Select saleDate, CONVERT(Date,SaleDate) as saleDateConverted
From NashvilleHousing

-- hago el update de la conversion
Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)



-- Me daba okey pero no se reflejaba el cambio asi que creo nueva col y modifico ahi
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- chequeo que si se hizo el cambio en nueva fila
Select saleDateConverted, CONVERT(Date,SaleDate) as saleDateConverted
From NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Veo que tengo muchos Property Adress NULL
Select UniqueID, PropertyAddress
From NashvilleHousing
where PropertyAddress is null


-- Veo que tengo muchos Property Adress que si tuviera referencia podria rellenar xq no va a cambiar de NULL
Select UniqueID, PropertyAddress
From NashvilleHousing
where PropertyAddress is null

--para filas repetidas que una no tiene propertyadress relleno con el valor de la repetida
Select rellenada.ParcelID, rellenada.PropertyAddress, relleno.ParcelID, relleno.PropertyAddress, ISNULL(rellenada.PropertyAddress,relleno.PropertyAddress)	-- cuando primero null ponele el valor del segundo
From NashvilleHousing rellenada
JOIN NashvilleHousing relleno
-- digo que para el mismo parcel ID y distinto Unique ID(row) donde en la rellenada es nulo,
-- en la lista rellenada se ponga el valor de la lista de relleno
	on rellenada.ParcelID = relleno.ParcelID
	AND rellenada.[UniqueID ] <> relleno.[UniqueID ]
Where rellenada.PropertyAddress is null


Update rellenada
SET PropertyAddress = ISNULL(rellenada.PropertyAddress,relleno.PropertyAddress)
From NashvilleHousing rellenada
JOIN NashvilleHousing relleno
	on rellenada.ParcelID = relleno.ParcelID
	AND rellenada.[UniqueID ] <> relleno.[UniqueID ]
Where rellenada.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Separar el adress en dos columnas con substring (Address, City, State)


Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
-- digo que arranque en 1 y busque hasta encontrar una coma y se quede con un char menos
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Street
-- digo que agarre el resto desp de la coma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From NashvilleHousing

-- creo y seteo columna para la calle
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- creo y seteo columna para la ciudad
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- chequeo que quedo todo bien
Select *
From NashvilleHousing







-- aca tengo lo mismo pero voy a usar parseName y tambien tengo nulls
Select OwnerAddress
From [Housing Data].dbo.NashvilleHousing


Select
-- busco comas y lo cambio a un punto y me lo devuelve inverso asi q lo pongo en orden desc
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Adress
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as StateIn
From [Housing Data].dbo.NashvilleHousing


-- creo filas y guardo datos como antes
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [Housing Data].dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Cambio en Sold Vacant los valores Y y N a Yes y No


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Housing Data].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



-- uso un case switch
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Housing Data].dbo.NashvilleHousing

-- desp de ver que el cambio es correcto lo updateo
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Sacar filas duplicadas con un cte

WITH numFilaCTE AS(
Select *,
-- uso el numero de fila como id y parto segun si todos estos parametros son iguales
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) numFila

From [Housing Data].dbo.NashvilleHousing
--order by ParcelID

)

-- ACA LAS BORRO LAS QUE ESTAN EXTRA
DELETE
From numFilaCTE
Where numFila > 1
Order by PropertyAddress


SELECT *
From numFilaCTE
Where numFila > 1
Order by PropertyAddress

Select *
From [Housing Data].dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Borrar columnas innecesarias, buena practica
Select *
From [Housing Data].dbo.NashvilleHousing

-- borre las que cambie
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
