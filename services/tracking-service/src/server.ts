import app from './app';
const PORT = parseInt(process.env.PORT || '8002', 10);
app.listen(PORT, () => console.log(`tracking-service listening on port ${PORT}`));
