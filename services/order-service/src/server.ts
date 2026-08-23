import app from './app';

const PORT = parseInt(process.env.PORT || '8001', 10);

app.listen(PORT, () => {
  console.log(`order-service listening on port ${PORT}`);
});
