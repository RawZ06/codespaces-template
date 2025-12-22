import Fastify from 'fastify';

const fastify = Fastify({
  logger: true
});

// Route Hello World
fastify.get('/hello', async (request, reply) => {
  return { message: 'Hello World from Fastify!' };
});

// Health check
fastify.get('/health', async (request, reply) => {
  return { status: 'ok' };
});

const start = async () => {
  try {
    await fastify.listen({ port: 3000, host: '0.0.0.0' });
    console.log('Server listening on http://localhost:3000');
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
