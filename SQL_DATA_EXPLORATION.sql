Create Database PortfolioDatabase

USE PortfolioDatabase
/*
Select *
From CovidDeaths

Select *
From CovidVaccination
*/

Select *
From PortfolioDatabase.dbo.Covid_Deaths
Order by 3,4

Select *
From PortfolioDatabase..Covid_Vaccination
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioDatabase.dbo.Covid_Deaths
Order by 1,2

--ALTER TABLE PortfolioDatabase..Covid_Deaths 
--ALTER COLUMN total_cases float


-- A. Total Cases Vs Total Deaths
--(Shows likelihood of dying if you contract Covid in Your Country)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) AS death_percent
From PortfolioDatabase.dbo.Covid_Deaths
Order by 1,2

Select [location],[date],[total_cases],[total_deaths], [total_deaths]/[total_cases] * 100 AS death_percent
From [PortfolioDatabase]..[Covid_Deaths] 
Order By 1, 2

Select [location],[date],[total_cases],[total_deaths], [total_deaths]/[total_cases] * 100 AS death_percent
From [PortfolioDatabase]..[Covid_Deaths] 
Where [location] like 'INDIA'
Order By 1, 2

-- B. Looking At Total Cases Vs Population
--( Shows percentage of Population got Covid )

Select [location],[date],[total_cases],[Population], [total_cases]/[Population] * 100 AS death_percent
From [PortfolioDatabase]..[Covid_Deaths] 
Where [location] like 'INDIA'
Order By 1, 2

Select [location],[date],[total_cases],[Population], [total_cases]/[Population] * 100 AS death_percent
From [PortfolioDatabase]..[Covid_Deaths] 
Order By 1, 2

-- C. Looking at Countries with Highest Infection Rate compared to Population
-- (Shows highest infection rate in your country)

Select [location],[Population], MAX([total_cases]) as highest_infection, MAX([total_cases]/[Population]) * 100 AS percentage_population_infected
From [PortfolioDatabase]..[Covid_Deaths] 
Group by [population], [location]
Order By percentage_population_infected desc

Select [location],[Population], MAX([total_cases]) as highest_infection, MAX([total_cases]/[Population]) * 100 AS percentage_population_infected
From [PortfolioDatabase]..[Covid_Deaths] 
Where [location] like 'INDIA'
Group by [population], [location]
Order By percentage_population_infected desc

-- D. Looking at Highest Death Count per Population
-- ( Showing Highest Death Count per Population)

Select [location],MAX(cast(total_deaths AS int)) As total_death_count
From [PortfolioDatabase]..[Covid_Deaths] 
Group by [location]
Order By total_death_count desc

-- E. Looking at Highest Death Count per Population by Continent
-- (Showing Highest Death Count per population by Continent)

Select continent,MAX(cast(total_deaths AS int)) As total_death_count
From [PortfolioDatabase]..[Covid_Deaths] 
Where continent is not null
Group by continent
Order By total_death_count desc

--(Showing Highest Death Count per population by Location)
Select location,MAX(cast(total_deaths AS int)) As total_death_count
From [PortfolioDatabase]..[Covid_Deaths] 
Where continent is not null
Group by location
Order By total_death_count desc

-- F. Max Death Count by Continent
-- Showing continents with Highest Death Count

Select continent,MAX(cast(total_deaths AS int)) As total_death_count
From [PortfolioDatabase]..[Covid_Deaths] 
Where continent is not null
Group by continent
Order By total_death_count desc

-- G. Global Numbers 
-- Showing total cases, total deaths, death percentage
Select 
	SUM(S.[new_cases])AS total_cases,
	SUM(S.[new_deaths])AS total_deaths,
	SUM(S.[new_deaths])/SUM(S.[new_cases])* 100 AS deathpercentage	
From [PortfolioDatabase]..[Covid_Deaths] AS S
Where continent is not null
Order By 1, 2

-- Showing total cases, total deaths, death percentage group by date
Select 
	S.[date],
	SUM(S.[new_cases])AS total_cases,
	SUM(S.[new_deaths])AS total_deaths,
	SUM(S.[new_deaths]) / NULLIF(SUM(S.[new_cases]), 0) * 100 AS deathpercentage
From [PortfolioDatabase]..[Covid_Deaths] AS S
Where continent is not null
group by [date]
Order By 1, 2

-- H. Total Population VS Vaccination

Select *
From [PortfolioDatabase]..[Covid_Deaths] CD
JOIN [PortfolioDatabase]..Covid_Vaccination CV
	ON CD.[location]=CV.[location]
	AND CD.[date]=CV.[date]

-- USE CTE
With POPvsVAC (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
AS
(
Select CD.[continent],CD.[location],CD.[date],CD.[population],CV.[new_vaccinations],
SUM(CAST(CV.[new_vaccinations] AS bigint)) OVER (PARTITION BY CD.[location] Order BY CD.[location],CD.[date]) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/CD.[population])*100 
From [PortfolioDatabase]..[Covid_Deaths] CD
JOIN [PortfolioDatabase]..Covid_Vaccination CV
	ON CD.[location]=CV.[location]
	AND CD.[date]=CV.[date]
Where CD.[continent] is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS total_people_vaccinated
From POPvsVAC

-- I. Create Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent nvarchar (255),
    Location nvarchar (255),
    Date datetime,
    Population float,
    New_vaccination bigint,
    RollingPeopleVaccinated bigint,
)

Insert into #PercentPopulationVaccinated
Select
    CD.[continent],
    CD.[location],
    CD.[date],
    CD.[population],
    CV.[new_vaccinations],
    SUM(CAST(CV.[new_vaccinations] AS bigint)) OVER (PARTITION BY CD.[location] ORDER BY CD.[location], CD.[date]) AS RollingPeopleVaccinated
From [PortfolioDatabase]..Covid_Deaths CD
JOIN [PortfolioDatabase]..Covid_Vaccination CV
    ON CD.[location]=CV.[location]
    AND CD.[date]=CV.[date]
Where CD.[continent] is not null

Select *, CAST(RollingPeopleVaccinated AS float)/Population*100 AS total_people_vaccinated
FROM #PercentPopulationVaccinated

-- J. Create View to store data for visualization
Create View PercentPopulationVaccinated AS
Select
    CD.[continent],
    CD.[location],
    CD.[date],
    CD.[population],
    CV.[new_vaccinations],
    SUM(CAST(CV.[new_vaccinations] AS bigint)) OVER (PARTITION BY CD.[location] ORDER BY CD.[location], CD.[date]) AS RollingPeopleVaccinated
From [PortfolioDatabase]..Covid_Deaths CD
JOIN [PortfolioDatabase]..Covid_Vaccination CV
    ON CD.[location]=CV.[location]
    AND CD.[date]=CV.[date]
Where CD.[continent] is not null

Select *
From PercentPopulationVaccinated