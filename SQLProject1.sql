select *
from PortfolioProject..CovidDeaths
order by 3, 4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
-- looking at total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--looking at percentage of death of total cases in USA

select Location, date, total_cases, population, (total_cases/population) *100 as Percent_Population
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--looking at USA infection rate

select Location, max(total_cases) as HighestCaseCount, population, max((total_cases/population)) *100 as HighestPercentInfected
from PortfolioProject..CovidDeaths
group by location, population
order by HighestPercentInfected desc

--looking at highest case % by countries

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--looking at total_deaths as an integer and as by continent

select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--casting total_deaths as an integer and total_deaths by country

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by DeathPercentage desc 


With PopVsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select da.continent, da.location, da.date, da.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by da.location order by da.location, da.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as da
join PortfolioProject..CovidVaccinations as vac 
on da.location = vac.location 
and da.date = vac.date
--order by 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated
from PopVsVac

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select da.continent, da.location, da.date, da.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by da.location order by da.location, da.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as da
join PortfolioProject..CovidVaccinations as vac 
on da.location = vac.location 
and da.date = vac.date
where da.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population) *100
From #PercentPopulationVaccinated

create view RollingPeopleVaccinated as 
select da.continent, da.location, da.date, da.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by da.location order by da.location, da.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as da
join PortfolioProject..CovidVaccinations as vac 
on da.location = vac.location 
and da.date = vac.date
--order by 2, 3