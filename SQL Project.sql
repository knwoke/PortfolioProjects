Select *
From Portfolio_Project..covid_deaths$

Select Location, date, total_cases, new_cases, total_Deaths, population
	From Portfolio_Project..covid_deaths$
	order by 1,2


--Shows likelihood of dying from covid in your country

Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
	From Portfolio_Project..covid_deaths$
	--Where location like '%Africa%'
	order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
	From Portfolio_Project..covid_deaths$
	--Where location like '%Africa%'
	Group by  Location, population
	order by PercentagePopulationInfected desc


--showing continents with the highest death count per population

Select continent,  MAX(cast(total_cases as int)) as TotalDeathCount
	From Portfolio_Project..covid_deaths$
	--Where location like '%Africa%'
	Where continent is not null
	Group by continent
	order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent,  MAX(cast(total_cases as int)) as TotalDeathCount
	From Portfolio_Project..covid_deaths$
	--Where location like '%Africa%'
	Where continent is not null
	Group by continent
	order by TotalDeathCount desc
	
	
-- Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
	From Portfolio_Project..covid_deaths$
	--Where location like '%Africa%'
	Where continent is not null
	--Group By date
	order by 1,2


--Looking a Total Population vs Vaccincations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--
From Portfolio_Project..covid_deaths$ dea
Join Portfolio_Project..covid_vaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3


 --USE CTE to perform Calculation on Partition By in previous query

 With PopvsVac (Continent, Location, Date, population, New_Vaccinations, RollingPeopleVaccinated) as 
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_deaths$ dea
Join Portfolio_Project..covid_vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255)
Location nvarchar(255)
Date datetime
Population numeric,
New_vaccinations numeric
RollingPeopleVaccinated numeric

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_deaths$ dea
Join Portfolio_Project..covid_vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
	

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
