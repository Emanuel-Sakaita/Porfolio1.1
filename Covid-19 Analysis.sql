


--Select * from dbo.['covid vax$']
--order by 3,4;

--select * from dbo.['owid-covid-data$']
--order by 3,4

--Data I am using 
select date,location, total_cases, new_cases, total_deaths, population
from dbo.['owid-covid-data$']
where continent is not null
order by 3,4;

--looking into total Cases vs total Deaths 
select date,location, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) As death_percentage 
from dbo.['owid-covid-data$']
where location like '%states%' 
and continent is not null
order by 3,4;

--convert total deaths to int
ALTER TABLE dbo.['owid-covid-data$']
ALTER COLUMN total_deaths decimal 

--convert total cases to int
ALTER TABLE dbo.['owid-covid-data$']
ALTER COLUMN total_cases decimal 

--Total cases vs Population 
select date,location,population, total_cases, round((total_cases/population)*100, 2) As populationinfected_percentage 
from dbo.['owid-covid-data$']
--where location like '%united states%'
order by 3,4;

--looking at the countries with the highest infection rate vs population 
select location, population, Max(total_cases) as HighestInfectionCount, round(Max((total_cases/population)*100), 2)
As percentage_of_infected_Population 
from dbo.['owid-covid-data$']
--where location like '%united states%'
group by location, population
order by percentage_of_infected_Population desc;

--countries with the highest death rate vs population
select location, population, Max(total_deaths) as HighestDeathCount, round(Max((total_deaths/population)*100), 2)
As percentage_of_deaths_Population 
from dbo.['owid-covid-data$']
--where location like '%united states%'
group by location, population
order by percentage_of_deaths_Population desc;

--Countries with the highest death count 
select location, Max(total_deaths) as Total_Death_Count
from dbo.['owid-covid-data$']
--where location like '%united states%'
where continent is not null
group by location
order by Total_Death_Count desc;

--Continent with the highest death count 
select continent, Max(total_deaths) as Total_Death_Count_By_Continent 
from dbo.['owid-covid-data$']
--where location like '%united states%'
where continent is not null
group by continent
order by Total_Death_Count_By_Continent desc;


--Looking at Global new Cases and deaths 
Select SUM(new_cases) as total_new_cases, sum(new_deaths) as total_new_deaths, round((sum(new_deaths)/SUM(new_cases))*100, 2) As death_percentage 
from dbo.['owid-covid-data$']
Where continent is not null;

--Join the two tables 
SELECT* from dbo.['owid-covid-data$'] dea
Join dbo.['covid vax$'] vax
On dea.location = vax.location
and dea.date  = vax.date

--looking at total popluation vs vaccination 
SELECT  dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(vax.new_vaccinations) over ( partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
from dbo.['owid-covid-data$'] dea
Join dbo.['covid vax$'] vax
On dea.location = vax.location
and dea.date  = vax.date
where dea.continent is not null
order by 2,3 

--convert covid vax column new_vaccinations 
ALTER TABLe dbo.['covid vax$']
ALTER COLUMN new_vaccinations decimal 

--Creating CTE
With popvsvax as (SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(vax.new_vaccinations) over ( partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
from dbo.['owid-covid-data$'] dea
Join dbo.['covid vax$'] vax
On dea.location = vax.location
and dea.date  = vax.date
where dea.continent is not null
)
Select*, (RollingpeopleVaccinated/population)*100
from popvsvax