import { Body, Controller, Get, Post } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Post()
  createMensagem(@Body() body: {message: string}) {
    console.log('Message received from user:', body);
    return this.appService.sendToConsumer(body.message);
  }

}
