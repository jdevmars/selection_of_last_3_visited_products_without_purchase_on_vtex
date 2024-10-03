-- apresentação dos últimos 3 produtos visualizados, porém não comprados

-- contagem de quantos produtos possuem preço com desconto maior que o preço original
SELECT COUNT(*) AS Contagem
FROM dt_Sku AS S
WHERE Price > ListPrice


-- exibição dos nomes dos produtos com preços incorretos (preço com desconto maior que o preço original)
SELECT ProductName, ListPrice AS Preço_Original, Price AS Preço_Desconto
FROM dt_Sku AS S
WHERE Price > ListPrice
ORDER BY ProductName ASC


-- seleciona, incorretamente, produtos repetidos, se o mesmo for visualizado mais de uma vez
SELECT TOP 3 S.ProductName, S.ImageUrlBig, CONCAT('https://www.bisturi.com.br', S.DetailUrl) AS DetailUrl, FORMAT(S.Price, 'C2', 'pt-BR') as Price, 
FORMAT(S.ListPrice, 'C2', 'pt-BR') as ListPrice, IIF(S.ListPrice > S.Price, 1, 0) AS Mostra, WV.date
FROM dt_Sku AS S 
INNER JOIN dt_WebsiteVisits AS WV
ON WV.skuId = S.Id
WHERE 
WV.email = @email AND
WV.skuId NOT IN (SELECT OI.SkuId from dt_OrderItem AS OI) 
ORDER BY WV.date DESC


-- versão final COM ListPrice, eliminando repetidos de produtos visualizados mais de uma vez
SELECT TOP 3 S.ProductName, S.ImageUrlBig, CONCAT('https://www.bisturi.com.br', S.DetailUrl) AS DetailUrl, FORMAT(S.Price, 'C2', 'pt-BR') as Price, 
FORMAT(S.ListPrice, 'C2', 'pt-BR') as ListPrice, IIF(S.ListPrice > S.Price, 1, 0) AS Mostra, WV.date
FROM dt_Sku AS S
INNER JOIN dt_WebsiteVisits AS WV
ON WV.skuId = S.Id
WHERE 
WV.email = @email AND
WV.skuId NOT IN (SELECT OI.SkuId from dt_OrderItem AS OI) 
AND WV.date = (
    SELECT MAX(WV2.date)
    FROM dt_WebsiteVisits AS WV2
    WHERE WV2.skuId = WV.skuId
    AND WV2.email = @email
)GROUP BY 
    S.ProductName, 
    S.ImageUrlBig, 
    S.DetailUrl, 
    S.Price, 
    S.ListPrice, 
    date,
    IIF(S.ListPrice > S.Price, 1, 0)
ORDER BY WV.date DESC


-- versão final SEM ListPrice, eliminando repetidos de produtos visualizados mais de uma vez
SELECT TOP 3 S.ProductName, S.ImageUrlBig, CONCAT('https://www.bisturi.com.br', S.DetailUrl) AS DetailUrl, FORMAT(S.Price, 'C2', 'pt-BR') as Price, 
WV.date
FROM dt_Sku AS S
INNER JOIN dt_WebsiteVisits AS WV
ON WV.skuId = S.Id
WHERE 
WV.email = @email AND
WV.skuId NOT IN (SELECT OI.SkuId from dt_OrderItem AS OI) 
AND WV.date = (
    SELECT MAX(WV2.date)
    FROM dt_WebsiteVisits AS WV2
    WHERE WV2.skuId = WV.skuId
    AND WV2.email = @email
)
GROUP BY 
    S.ProductName, 
    S.ImageUrlBig, 
    S.DetailUrl, 
    S.Price, 
    date
ORDER BY WV.date DESC


-- seleção de e-mails pra teste
SELECT S.ProductName, WV.email
FROM dt_Sku AS S
INNER JOIN dt_WebsiteVisits AS WV
ON WV.skuId = S.Id
WHERE
WV.skuId NOT IN (SELECT OI.SkuId from dt_OrderItem AS OI) 
AND
WV.email IS NOT NULL
ORDER BY WV.email ASC
