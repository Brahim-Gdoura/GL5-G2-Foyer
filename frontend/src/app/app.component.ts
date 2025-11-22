import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <div class="header">
      <h1>🏢 Foyer Management System</h1>
    </div>
    <nav class="nav">
      <ul class="nav-links">
        <li>
          <a
            routerLink="/"
            routerLinkActive="active"
            [routerLinkActiveOptions]="{ exact: true }"
            >Home</a
          >
        </li>
        <li>
          <a routerLink="/universites" routerLinkActive="active"
            >Universities</a
          >
        </li>
        <li><a routerLink="/blocs" routerLinkActive="active">Blocs</a></li>
        <li>
          <a routerLink="/etudiants" routerLinkActive="active">Students</a>
        </li>
      </ul>
    </nav>
    <div class="container">
      <router-outlet></router-outlet>
    </div>
  `,
})
export class AppComponent {
  title = 'Foyer Management';
}
