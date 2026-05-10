import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface CreateShortLinkRequest {
  originalLink: string;
}

export interface CreateShortLinkResponse {
  originalLink: string;
  shortLink: string;
}

@Injectable({ providedIn: 'root' })
export class ShortenerApiService {
  private readonly apiUrl = `${environment.apiBaseUrl}/api/v1/links`;

  constructor(private readonly httpClient: HttpClient) {}

  createShortLink(payload: CreateShortLinkRequest): Observable<CreateShortLinkResponse> {
    return this.httpClient.post<CreateShortLinkResponse>(this.apiUrl, payload);
  }

  listLinks(): Observable<CreateShortLinkResponse[]> {
    return this.httpClient.get<CreateShortLinkResponse[]>(this.apiUrl);
  }
}
