import app from './app';
const PORT = parseInt(process.env.PORT || '8003', 10);
app.listen(PORT, () => console.log(`notification-service listening on port ${PORT}`));
