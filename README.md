Proyecto de Limpieza de Datos en SQL
Visión general
En este proyecto, he llevado a cabo la limpieza y transformación de datos utilizando SQL. El conjunto de datos se centra en información relacionada con viviendas en Nashville. A través de consultas SQL específicas, se realizaron diversas tareas de limpieza para mejorar la calidad y utilidad de los datos.

Configuración del Proyecto
Para implementar este proyecto, sigue estos pasos:

Guarda los archivos de Excel en una ubicación accesible para tu entorno SQL.
Utiliza la función 'Importar Datos' en tu base de datos (en este caso, 'NashvilleHousing').
Ejecuta las consultas SQL proporcionadas para llevar a cabo la limpieza y transformación de datos.
Consultas SQL
1. Estandarización del Formato de Fecha
sql
Copy code
-- Visualizar formato actual y convertir
SELECT saleDate, CONVERT(Date, SaleDate) as saleDateConverted
FROM NashvilleHousing;

-- Realizar la actualización
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);
2. Relleno de Valores Nulos en la Dirección de Propiedades
sql
Copy code
-- Identificar filas con PropertyAddress NULL
SELECT UniqueID, PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

-- Rellenar valores NULL en PropertyAddress cuando sea posible
UPDATE rellenada
SET PropertyAddress = ISNULL(rellenada.PropertyAddress, relleno.PropertyAddress)
FROM NashvilleHousing rellenada
JOIN NashvilleHousing relleno
    ON rellenada.ParcelID = relleno.ParcelID
    AND rellenada.[UniqueID ] <> relleno.[UniqueID ]
WHERE rellenada.PropertyAddress IS NULL;
3. Separación de la Dirección en Dos Columnas
sql
Copy code
-- Separar la dirección en dos columnas (Street y City)
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) as Street,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
FROM NashvilleHousing;

-- Crear y setear nuevas columnas
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 );

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));
4. Parseo de la Dirección del Propietario
sql
Copy code
-- Utilizar PARSENAME para dividir la dirección del propietario
SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
FROM NashvilleHousing;

-- Crear y setear nuevas columnas
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);
5. Cambio en SoldAsVacant a Yes y No
sql
Copy code
-- Cambiar valores Y y N en SoldAsVacant a Yes y No
UPDATE NashvilleHousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;
6. Eliminación de Filas Duplicadas
sql
Copy code
-- Eliminar filas duplicadas utilizando una CTE
WITH numFilaCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) numFila
    FROM NashvilleHousing
)

-- Borrar las filas duplicadas
DELETE FROM numFilaCTE
WHERE numFila > 1;

-- Verificar que las filas duplicadas fueron eliminadas
SELECT *
FROM numFilaCTE
WHERE numFila > 1;
7. Eliminación de Columnas Innecesarias
sql
Copy code
-- Eliminar columnas innecesarias
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
Notas
Estas consultas abordan diversas tareas de limpieza y transformación de datos para mejorar la calidad de la información.
Realiza ajustes según sea necesario para tu entorno SQL específico.
Las consultas están diseñadas para ser ejecutadas sec


Data Cleaning Project in SQL
Overview
In this data cleaning project, I performed various data cleaning and transformation tasks using SQL. The dataset focuses on housing information in Nashville. Through specific SQL queries, I addressed issues such as date format standardization, filling null values, splitting addresses, parsing owner addresses, changing values, removing duplicates, and dropping unnecessary columns.

Project Setup
To implement this project, follow these steps:

Save the Excel files in a location accessible to your SQL environment.
Use the 'Import Data' function in your database (in this case, 'NashvilleHousing').
Execute the provided SQL queries to perform data cleaning and transformation.
SQL Queries
1. Standardization of Date Format
sql
Copy code
-- View the current format and convert
SELECT saleDate, CONVERT(Date, SaleDate) as saleDateConverted
FROM NashvilleHousing;

-- Update the conversion
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);
2. Filling Null Values in Property Address
sql
Copy code
-- Identify rows with PropertyAddress NULL
SELECT UniqueID, PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

-- Fill NULL values in PropertyAddress where possible
UPDATE rellenada
SET PropertyAddress = ISNULL(rellenada.PropertyAddress, relleno.PropertyAddress)
FROM NashvilleHousing rellenada
JOIN NashvilleHousing relleno
    ON rellenada.ParcelID = relleno.ParcelID
    AND rellenada.[UniqueID ] <> relleno.[UniqueID ]
WHERE rellenada.PropertyAddress IS NULL;
3. Separation of Address into Two Columns
sql
Copy code
-- Separate the address into two columns (Street and City)
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) as Street,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
FROM NashvilleHousing;

-- Create and set new columns
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 );

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));
4. Parsing Owner Address
sql
Copy code
-- Use PARSENAME to split the owner's address
SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
FROM NashvilleHousing;

-- Create and set new columns
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);
5. Change in SoldAsVacant to Yes and No
sql
Copy code
-- Change values Y and N in SoldAsVacant to Yes and No
UPDATE NashvilleHousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;
6. Deletion of Duplicate Rows
sql
Copy code
-- Delete duplicate rows using a CTE
WITH numFilaCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) numFila
    FROM NashvilleHousing
)

-- Delete duplicate rows
DELETE FROM numFilaCTE
WHERE numFila > 1;

-- Verify that duplicate rows were deleted
SELECT *
FROM numFilaCTE
WHERE numFila > 1;
7. Deletion of Unnecessary Columns
sql
Copy code
-- Delete unnecessary columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
Notes
These queries address various data cleaning and transformation tasks to improve the quality of the information.
Make adjustments as needed for your specific SQL environment.
The queries are designed to be executed in sequence to achieve the desired data
