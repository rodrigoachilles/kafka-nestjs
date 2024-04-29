import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';

async function bootstrap() {
  const app = await NestFactory.createMicroservice<MicroserviceOptions>(
    AppModule,
    {
      transport: Transport.KAFKA,
      options: {
        client: {
          clientId: 'kafka',
          brokers: ['kafka-1:9092', 'kafka-2:9092', 'kafka-3:9092'],
        },
        run: {
          autoCommit: true,
        },
        consumer: {
          groupId: 'my-kafka',
          readUncommitted: false,
        },
        subscribe: {
          fromBeginning: true,
        },
      },
    },
  );

  app.listen();
}
bootstrap();
