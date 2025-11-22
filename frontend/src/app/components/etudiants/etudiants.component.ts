import { Component, OnInit } from '@angular/core';
import { ApiService, Etudiant } from '../../services/api.service';

@Component({
  selector: 'app-etudiants',
  template: `
    <div class="card">
      <h2>Students</h2>
      <div *ngIf="loading" class="loading">Loading students...</div>
      <div *ngIf="error" class="error">{{ error }}</div>
      <div *ngIf="!loading && etudiants.length === 0" class="empty-state">
        No students found. The database is empty.
      </div>
      <table *ngIf="!loading && etudiants.length > 0">
        <thead>
          <tr>
            <th>ID</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>CIN</th>
            <th>Birth Date</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let etudiant of etudiants">
            <td>{{ etudiant.idEtudiant }}</td>
            <td>{{ etudiant.prenomEtudiant }}</td>
            <td>{{ etudiant.nomEtudiant }}</td>
            <td>{{ etudiant.cinEtudiant }}</td>
            <td>{{ etudiant.dateNaissance | date }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
})
export class EtudiantsComponent implements OnInit {
  etudiants: Etudiant[] = [];
  loading = false;
  error = '';

  constructor(private apiService: ApiService) {}

  ngOnInit() {
    this.loadEtudiants();
  }

  loadEtudiants() {
    this.loading = true;
    this.error = '';
    this.apiService.getEtudiants().subscribe({
      next: (data) => {
        this.etudiants = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load students: ' + err.message;
        this.loading = false;
      },
    });
  }
}
