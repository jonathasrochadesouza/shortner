import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CreateShortLinkResponse, ShortenerApiService } from '../services/shortener-api.service';

@Component({
  selector: 'app-links',
  imports: [RouterLink],
  templateUrl: './links.html',
  styleUrl: './links.scss',
})
export class LinksComponent implements OnInit {
  private readonly api = inject(ShortenerApiService);

  protected readonly links   = signal<CreateShortLinkResponse[]>([]);
  protected readonly loading = signal(true);
  protected readonly error   = signal<string | null>(null);
  protected readonly copied  = signal<string | null>(null);

  ngOnInit(): void {
    this.api.listLinks().subscribe({
      next: (data) => { this.links.set(data); this.loading.set(false); },
      error: ()     => { this.error.set('Could not load the links. Please try again.'); this.loading.set(false); },
    });
  }

  protected copyLink(url: string): void {
    navigator.clipboard.writeText(url).then(() => {
      this.copied.set(url);
      setTimeout(() => this.copied.set(null), 2500);
    });
  }

  protected truncate(url: string, max = 60): string {
    return url.length > max ? url.slice(0, max) + '…' : url;
  }
}
