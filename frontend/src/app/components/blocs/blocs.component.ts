import { Component, OnInit } from '@angular/core';
import { ApiService, Bloc } from '../../services/api.service';

@Component({
  selector: 'app-blocs',
  template: `
    <div class="card">
      <h2>Housing Blocs</h2>
      <div *ngIf="loading" class="loading">Loading blocs...</div>
      <div *ngIf="error" class="error">{{ error }}</div>
      <div *ngIf="!loading && blocs.length === 0" class="empty-state">
        No blocs found. The database is empty.
      </div>
      <table *ngIf="!loading && blocs.length > 0">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Capacity</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let bloc of blocs">
            <td>{{ bloc.idBloc }}</td>
            <td>{{ bloc.nomBloc }}</td>
            <td>{{ bloc.capaciteBloc }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
})
export class BlocsComponent implements OnInit {
  blocs: Bloc[] = [];
  loading = false;
  error = '';

  constructor(private apiService: ApiService) {}

  ngOnInit() {
    this.loadBlocs();
  }

  loadBlocs() {
    this.loading = true;
    this.error = '';
    this.apiService.getBlocs().subscribe({
      next: (data) => {
        this.blocs = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load blocs: ' + err.message;
        this.loading = false;
      },
    });
  }
}
