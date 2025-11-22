import { Component } from '@angular/core';

@Component({
  selector: 'app-home',
  template: `
    <div class="card">
      <h2>Welcome to Foyer Management System</h2>
      <p>This system allows you to manage:</p>
      <ul>
        <li>
          <strong>Universities</strong> - View and manage university information
        </li>
        <li>
          <strong>Blocs</strong> - Manage housing blocs and their capacity
        </li>
        <li>
          <strong>Students</strong> - Track student information and assignments
        </li>
      </ul>
      <p style="margin-top: 20px;">
        Use the navigation menu above to explore different sections.
      </p>
    </div>
  `,
  styles: [
    `
      ul {
        margin: 20px 0;
        padding-left: 40px;
      }
      li {
        margin: 10px 0;
        line-height: 1.6;
      }
    `,
  ],
})
export class HomeComponent {}
