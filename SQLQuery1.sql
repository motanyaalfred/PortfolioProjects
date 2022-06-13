select *
from [Portfolio Database]..coviddeaths
where continent is not null
order by 3,4


--select *
--from [Portfolio Database]..covidvaccine
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Database]..coviddeaths
order by 1,2

--Total cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Database]..coviddeaths
where location like '%Kenya%'
order by 1,2

--Looking at the Total Cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as InnfectionPercentage
from [Portfolio Database]..coviddeaths
where location like '%Kenya%'
order by 1,2

--Countries with highest infection rate per population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as TotalInfectedPop
from [Portfolio Database]..coviddeaths
Group by location, population
order by TotalInfectedPop desc

--Showing countries with highest total deaths per population

select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((total_deaths/population))*100 as TotalDeathsPop
from [Portfolio Database]..coviddeaths
where continent is not null
Group by location,population
order by TotalDeathsPop desc

--Total counts per continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Database]..coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Database]..coviddeaths
where continent is null
Group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Database]..coviddeaths
where continent is null
--Group by date
order by 1,2

--LOOKING AT TOTAL POPULATION VS vACCINATIONS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingVaccinated
From [Portfolio Database]..coviddeaths dea
join [Portfolio Database]..covidvaccine vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null 
 and new_vaccinations is not null
order by 2,3   

--USE CTE
with popvsvac(continent, location, date, population, new_vaccinations, RollingVaccinated)
as 

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingVaccinated
From [Portfolio Database]..coviddeaths dea
join [Portfolio Database]..covidvaccine vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null 
 and new_vaccinations is not null
 --order by 2,3
 )
 select*, (RollingVaccinated/population)*100
 from popvsvac

 --TEMP TABLE

 Drop Table if exists  #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccination numeric,
 RollingVaccinated numeric
 )
 insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingVaccinated
From [Portfolio Database]..coviddeaths dea
join [Portfolio Database]..covidvaccine vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null 
 --and new_vaccinations is not null
 --order by 2,3
 select*, (RollingVaccinated/population)*100
 from #PercentPopulationVaccinated


  
  --CREATING DATA FOR LATER VISUALS
  Create View PercentPopulationVaccinated as
 Select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingVaccinated
From [Portfolio Database]..coviddeaths dea
join [Portfolio Database]..covidvaccine vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null 
 --and new_vaccinations is not null
 --order by 2,3

 Drop view if exists PercentPopulationVaccinated

 Select *
 From PercentPopulationVaccinated as bigint
