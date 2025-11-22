import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

const API_URL = '/tpFoyer17';

export interface Universite {
  idUniversite: number;
  nomUniversite: string;
  adresse: string;
}

export interface Bloc {
  idBloc: number;
  nomBloc: string;
  capaciteBloc: number;
}

export interface Etudiant {
  idEtudiant: number;
  nomEtudiant: string;
  prenomEtudiant: string;
  cinEtudiant: number;
  dateNaissance: string;
}

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  private apiUrl = API_URL;

  constructor(private http: HttpClient) {}

  getUniversites(): Observable<Universite[]> {
    return this.http.get<Universite[]>(`${this.apiUrl}/api/univeristes/getAll`);
  }

  getBlocs(): Observable<Bloc[]> {
    return this.http.get<Bloc[]>(`${this.apiUrl}/api/blocs/getAll`);
  }

  getEtudiants(): Observable<Etudiant[]> {
    return this.http.get<Etudiant[]>(`${this.apiUrl}/api/etudiants/getAll`);
  }
}
