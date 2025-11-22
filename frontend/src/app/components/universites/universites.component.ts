import { Component, OnInit } from '@angular/core';
import { ApiService, Universite } from '../../services/api.service';

@Component({
  selector: 'app-universites',
  template: `
    <div class="card">
      <h2>Universities</h2>
      <div *ngIf="loading" class="loading">Loading universities...</div>
      <div *ngIf="error" class="error">{{ error }}</div>
      <div *ngIf="!loading && universites.length === 0" class="empty-state">
        No universities found. The database is empty.
      </div>
      <table *ngIf="!loading && universites.length > 0">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Address</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let uni of universites">
            <td>{{ uni.idUniversite }}</td>
            <td>{{ uni.nomUniversite }}</td>
            <td>{{ uni.adresse }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
})
export class UniversitesComponent implements OnInit {
  universites: Universite[] = [];
  loading = false;
  error = '';

  constructor(private apiService: ApiService) {}

  ngOnInit() {
    this.loadUniversites();
  }

  loadUniversites() {
    this.loading = true;
    this.error = '';
    this.apiService.getUniversites().subscribe({
      next: (data) => {
        this.universites = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load universities: ' + err.message;
        this.loading = false;
      },
    });
  }
}
