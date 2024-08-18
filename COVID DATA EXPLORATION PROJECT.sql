-- WELCOME TO THE COVID - DATA EXPLORATION.SQL PROJECT

-- IMPORTING THE COVID DATA FROM THE BELOW SITE
-- https://ourworldindata.org/covid-deaths

-- MODIFYING THE DATA INTO TWO INDIVIDUAL TABLES i) COVID DEATHS  ii) COVID VACCINATIONS

-- selecting the both tables order by 3(column 3- continent) and (column 4 - location)
Select *
From  [portfolio project - SQL Data exploration].[dbo].[covid deaths]
Where continent is not null 
order by 3,4

Select *
From  [portfolio project - SQL Data exploration].[dbo].[covid vaccinations]
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
From  [portfolio project - SQL Data exploration].[dbo].[covid deaths]
where continent is not null
order by 1,2



-- Total Cases vs Total Deaths
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [portfolio project - SQL Data exploration].[dbo].[covid deaths]
order by 1,2

-- Shows likelihood of dying if you contract covid in your country
--we need to specify 'where continet is not null' otherwise the data will return the null continents data also it really gonna messed up the data
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [portfolio project - SQL Data exploration].[dbo].[covid deaths]
Where location like '%india%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [portfolio project - SQL Data exploration].[dbo].[covid deaths]
Where location like '%india%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From  [portfolio project - SQL Data exploration].[dbo].[covid deaths]
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
Select Location, MAX(Total_deaths) as TotalDeathCount
From  [portfolio project - SQL Data exploration].[dbo].[covid deaths]
Where continent is not null 
Group by Location
order by TotalDeathCount desc
-- In the above query the total_deaths column is in nvarchar data type that's why its is not performing in desc order

-- now, In the below query we cast the column total_death to int (cast to coverting data type) as it was in nvarchar
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From  [portfolio project - SQL Data exploration].[dbo].[covid deaths]
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From [portfolio project - SQL Data exploration].[dbo].[covid deaths]
Where continent is not null 
Group by continent
order by TotalDeathCount desc

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From [portfolio project - SQL Data exploration].[dbo].[covid deaths]
Where continent is null 
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

-- datewise total cases and total deaths
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
From [portfolio project - SQL Data exploration].[dbo].[covid deaths]
where continent is not null 
group by date
order by 1,2

-- overall total cases and total deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [portfolio project - SQL Data exploration].[dbo].[covid deaths]
where continent is not null 
order by 1,2


-- JOINING TWO TABLES (COVID DEATH & COVID VACCINATIONS)
select *
From [portfolio project - SQL Data exploration].[dbo].[covid deaths] dea
Join [portfolio project - SQL Data exploration].[dbo].[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccinations
select  dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int) as new_vaccinations
From [portfolio project - SQL Data exploration].[dbo].[covid deaths] dea
Join [portfolio project - SQL Data exploration].[dbo].[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [portfolio project - SQL Data exploration].[dbo].[covid deaths] dea
Join [portfolio project - SQL Data exploration].[dbo].[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--to calculate a running total of sales (cumulative_sales) for each sales representative, 
--you can use the SUM() window function with OVER and PARTITION BY: (for example)


--now to calculate the percentage also need to add one more column to make that we need to create CTE
--without CTE it gives an error like below 
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From [portfolio project - SQL Data exploration].[dbo].[covid deaths] dea
Join [portfolio project - SQL Data exploration].[dbo].[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- now,Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From [portfolio project - SQL Data exploration].[dbo].[covid deaths] dea
Join [portfolio project - SQL Data exploration].[dbo].[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percenatage_of_vaccinated_people
From PopvsVac

--A Common Table Expression (CTE) is a temporary result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. 
--CTEs can be used to simplify complex queries, improve readability, and help in structuring SQL queries more effectively. 
--They are especially useful for breaking down complex operations into more manageable parts






-- Using Temp Table to perform Calculation on Partition By in previous query

--Temporary tables are a flexible tool in SQL that allow you to create temporary storage for intermediate results,
--manage complex queries, and optimize performance.
--They are automatically cleaned up based on their type (local or global) and the session or transaction context in which they are used.

DROP Table if exists #PercentPopulationVaccinated    --it helps to drop the table and uses to run again and again
--creating table with needed columns
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
--inserting values to the above table
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project - SQL Data exploration].[dbo].[covid deaths] dea
Join [portfolio project - SQL Data exploration].[dbo].[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as percenatage_of_vaccinated_people
From #PercentPopulationVaccinated







-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project - SQL Data exploration].[dbo].[covid deaths] dea
Join [portfolio project - SQL Data exploration].[dbo].[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--to open views go to views and select first 1000 rows

select * from PercentPopulationVaccinated


