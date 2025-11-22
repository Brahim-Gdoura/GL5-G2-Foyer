import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { BlocsComponent } from './components/blocs/blocs.component';
import { EtudiantsComponent } from './components/etudiants/etudiants.component';
import { HomeComponent } from './components/home/home.component';
import { UniversitesComponent } from './components/universites/universites.component';

const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'universites', component: UniversitesComponent },
  { path: 'blocs', component: BlocsComponent },
  { path: 'etudiants', component: EtudiantsComponent },
];

@NgModule({
  declarations: [
    AppComponent,
    UniversitesComponent,
    BlocsComponent,
    EtudiantsComponent,
    HomeComponent,
  ],
  imports: [BrowserModule, HttpClientModule, RouterModule.forRoot(routes)],
  providers: [],
  bootstrap: [AppComponent],
})
export class AppModule {}
