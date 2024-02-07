const express = require('express');
const axios = require('axios');
const xml2js = require('xml2js');
const iconv = require('iconv-lite');
const app = express();
const port = 3000;

const apiKey = 'your ID';

app.get('/products', async (req, res) => {
  const keyword = req.query.keyword || '';
  try {
    const response = await axios({
      method: 'get',
      url: `11번가 카테고리 URL`,
      responseType: 'arraybuffer',
      responseEncoding: 'binary'
    });

    const utf8String = iconv.decode(Buffer.from(response.data), 'EUC-KR');

    const parser = new xml2js.Parser({ explicitArray: false });
    parser.parseString(utf8String, (err, result) => {
      if (err) {
        res.status(500).json({ error: 'Error occurred while parsing XML' });
        return;
      }

      const products = result.ProductSearchResponse.Products.Product;

      const formattedProducts = products.map(product => {
        return {
          id: product.ProductCode, // 제품 코드를 제품 ID로 사용합니다.
          image: product.ProductImage100,
          name: product.ProductName,
          detailUrl: product.DetailPageUrl,
        };
      });

      res.setHeader('Content-Type', 'application/json; charset=utf-8');
      res.json(formattedProducts);
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error occurred while fetching product data' });
  }
});

// 제품 삭제를 위한 DELETE 엔드포인트
// 실제 데이터베이스와 연동하여 제품을 삭제하는 로직이 필요합니다.
app.delete('/product', (req, res) => {
  const productId = req.query.id;
  // 여기에서 데이터베이스에서 제품을 삭제하는 로직을 구현합니다.
  // 예제에서는 단순히 요청을 받고 삭제되었다고 가정합니다.
  console.log(`Deleting product with ID: ${productId}`);
  // 삭제 성공 응답
  res.status(200).send(`Product with ID: ${productId} has been deleted.`);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
