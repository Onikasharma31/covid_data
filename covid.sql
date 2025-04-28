
select * 
from portfolioProject..CovidDeaths
order by 3,4


--select * 
--from portfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are using


select location , date , total_cases,new_cases , total_deaths, population
from portfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_cases = 0 OR total_cases IS NULL THEN 0
        ELSE (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT) * 100) 
    END AS death_rate 
FROM 
    portfolioProject..CovidDeaths
WHERE 
	location like 'india'
ORDER BY 
    location, date;

	-- looking at total cases vs population

	SELECT 
    location, 
    date, 
    total_cases, 
    population, 
    CASE 
        WHEN total_cases = 0 OR total_cases IS NULL THEN 0
        ELSE (CAST(total_deaths AS FLOAT) / CAST(population AS FLOAT) * 100) 
    END AS covid_cases
FROM 
    portfolioProject..CovidDeaths
WHERE 
	location like 'india'
ORDER BY 
    location, date;

--country with higest cases compared to population

SELECT 
    location, 
    MAX(CAST(total_cases AS BIGINT)) AS highest_cases, 
    MAX(CAST(total_deaths AS BIGINT)) AS total_deaths, 
    CASE 
        WHEN MAX(CAST(population AS BIGINT)) = 0 OR MAX(CAST(population AS BIGINT)) IS NULL THEN 0
        ELSE (MAX(CAST(total_cases AS FLOAT)) / MAX(CAST(population AS FLOAT))) * 100 
    END AS infected_population 
FROM 
    portfolioProject..CovidDeaths
GROUP BY 
    location
ORDER BY 
    infected_population desc;


-- highest death count


SELECT 
    location, 
    MAX(cast(total_deaths as int)) as death_count
FROM 
    portfolioProject..CovidDeaths
GROUP BY 
    location
ORDER BY 
    death_count desc;


-- SHOWING THE CONTINENT WITH HIGHEST DEATH COUNT

SELECT 
    continent, 
    MAX(cast(total_deaths as int)) as death_count
FROM 
    portfolioProject..CovidDeaths
GROUP BY 
    continent
ORDER BY 
    death_count desc;


--GLOBAL NUMBERS 


SELECT  
    date, 
    SUM(CAST(new_cases AS BIGINT)) AS new_cases,
    SUM(CAST(new_deaths AS BIGINT)) AS new_deaths,
    CASE 
        WHEN SUM(CAST(new_cases AS BIGINT)) = 0 THEN 0
        ELSE (SUM(CAST(new_deaths AS FLOAT))) / SUM(CAST(new_cases AS FLOAT))*100
    END AS death_percentage
FROM 
    portfolioProject..CovidDeaths
--WHERE location LIKE 'india'
GROUP BY 
    date
ORDER BY 
    date;


	-- looking at total population vs vaccination 


		-- use CTE 
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        CAST(dea.population AS BIGINT) AS population,  -- Cast population to BIGINT
        CAST(vac.new_vaccinations AS BIGINT) AS new_vaccinations,  -- Cast vaccinations also to BIGINT
        SUM(CAST(vac.new_vaccinations AS BIGINT)) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
    FROM 
        portfolioProject..CovidDeaths dea
    JOIN 
        portfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    *,
    CASE 
        WHEN population IS NULL OR population = 0 THEN NULL
        ELSE (CAST(rolling_people_vaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100
    END AS rolling_vaccinated_percentage
FROM 
    pop_vs_vac;


	-- CREATING VIEW


USE portfolioProject;
    GO

	CREATE VIEW PERCENTAGE_POP_VAC AS
	  SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        CAST(dea.population AS BIGINT) AS population,  -- Cast population to BIGINT
        CAST(vac.new_vaccinations AS BIGINT) AS new_vaccinations,  -- Cast vaccinations also to BIGINT
        SUM(CAST(vac.new_vaccinations AS BIGINT)) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
    FROM 
        portfolioProject..CovidDeaths dea
    JOIN 
        portfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
	

	SELECT *
	FROM 
	PERCENTAGE_POP_VAC




