import {Component} from 'angular2/core';
import {bootstrap} from 'angular2/platform/browser'

@Component({
    selector: '#sidebar',
    templateUrl: __dirname + '/html/index.html'
})

export class SidebarComponent{
  test: string;

  constructor(){
    this.test = "abc";
  }
}

bootstrap(SidebarComponent);
