const axios = require('axios');

const { BUCKET_NAME } = require('./config.json');
/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.helloGET = async (req, res) => {
  // let message = req.query.message || req.body.message || 'Hello World!';
  // res.status(200).send(message);
  try{
    const {data} = await axios.get(`https://storage.googleapis.com/${BUCKET_NAME}/html/index.html`);
    res.send(data);
  } catch(e) {
    console.error(e)
  }
};
