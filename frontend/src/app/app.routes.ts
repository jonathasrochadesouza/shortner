import { Routes } from '@angular/router';
import { HomeComponent } from './home/home';
import { LinksComponent } from './links/links';
import { NotFoundComponent } from './not-found/not-found';
import { RedirectComponent } from './redirect/redirect';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'links', component: LinksComponent },
  { path: ':shortCode', component: RedirectComponent },
  { path: '**', component: NotFoundComponent },
];
